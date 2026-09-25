package dev.templates.addons.android_media_store_gateway

import android.app.Activity
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** MediaStoreへのメディアコレクション操作をDart Gatewayへ提供する。 */
class AndroidMediaStoreGatewayPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingOperation: PendingExport? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "organizeCollection") {
            result.notImplemented()
            return
        }
        if (pendingOperation != null) {
            result.error("operation_in_progress", "A media collection operation is already in progress.", null)
            return
        }
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("activity_unavailable", "Media collection operation requires an Activity.", null)
            return
        }
        val request = parseRequest(call.arguments)
        if (request == null) {
            result.error("invalid_request", "The media collection request is invalid.", null)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.success(unavailableResult(request))
            return
        }

        val assetIds = request.groups.flatMap { it.assetIds }
        if (assetIds.isEmpty()) {
            result.success(emptyResult())
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val uris = assetIds.mapNotNull(::imageUri).filter {
                assetExists(currentActivity, it)
            }
            if (uris.isEmpty()) {
                result.success(movePhotos(request, currentActivity))
                return
            }
            try {
                val permissionIntent = MediaStore.createWriteRequest(
                    currentActivity.contentResolver,
                    uris,
                )
                pendingOperation = PendingExport(request, result)
                currentActivity.startIntentSenderForResult(
                    permissionIntent.intentSender,
                    WRITE_REQUEST_CODE,
                    null,
                    0,
                    0,
                    0,
                )
            } catch (_: SecurityException) {
                result.success(permissionDeniedResult(request))
            }
            return
        }

        result.success(movePhotos(request, currentActivity))
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != WRITE_REQUEST_CODE) return false
        val pending = pendingOperation ?: return false
        pendingOperation = null
        val currentActivity = activity
        if (resultCode != Activity.RESULT_OK) {
            pending.result.success(cancelledResult(pending.request))
        } else if (currentActivity == null) {
            pending.result.error("activity_unavailable", "Media collection operation requires an Activity.", null)
        } else {
            pending.result.success(movePhotos(pending.request, currentActivity))
        }
        return true
    }

    private fun movePhotos(request: CollectionRequest, currentActivity: Activity): Map<String, Any> {
        val exported = mutableListOf<String>()
        val failures = mutableListOf<Map<String, String>>()
        val root = if (request.destination == "dcim") "DCIM" else "Pictures"
        request.groups.forEach { group ->
            val relativePath = "$root/${request.containerName}/${group.name}/"
            group.assetIds.forEach { assetId ->
                val uri = imageUri(assetId)
                if (uri == null || !assetExists(currentActivity, uri)) {
                    failures += failure(assetId, "assetNotFound")
                    return@forEach
                }
                try {
                    val values = ContentValues().apply {
                        put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                    }
                    val updated = currentActivity.contentResolver.update(uri, values, null, null)
                    if (updated > 0) {
                        exported += assetId
                    } else {
                        failures += failure(assetId, "unavailable")
                    }
                } catch (_: SecurityException) {
                    failures += failure(assetId, "permissionDenied")
                } catch (_: Exception) {
                    failures += failure(assetId, "unexpected")
                }
            }
        }
        return mapOf("exportedPhotoAssetIds" to exported, "failures" to failures)
    }

    private fun assetExists(activity: Activity, uri: android.net.Uri): Boolean =
        activity.contentResolver.query(uri, arrayOf(MediaStore.MediaColumns._ID), null, null, null)
            ?.use { it.moveToFirst() } == true

    private fun imageUri(assetId: String): android.net.Uri? {
        val numericId = assetId.toLongOrNull() ?: return null
        return ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, numericId)
    }

    @Suppress("UNCHECKED_CAST")
    private fun parseRequest(arguments: Any?): CollectionRequest? {
        val map = arguments as? Map<String, Any?> ?: return null
        val containerName = map["containerName"] as? String ?: return null
        val destination = map["destination"] as? String ?: "pictures"
        val groups = (map["groups"] as? List<Map<String, Any?>>)?.mapNotNull { group ->
            val name = group["name"] as? String ?: return@mapNotNull null
            val ids = (group["photoAssetIds"] as? List<*>)?.filterIsInstance<String>()
                ?: return@mapNotNull null
            CollectionGroup(name, ids)
        } ?: return null
        return CollectionRequest(containerName, destination, groups)
    }

    private fun unavailableResult(request: CollectionRequest): Map<String, Any> = mapOf(
        "exportedPhotoAssetIds" to emptyList<String>(),
        "failures" to request.groups.flatMap { group ->
            group.assetIds.map { failure(it, "unavailable") }
        },
    )

    private fun cancelledResult(request: CollectionRequest): Map<String, Any> = mapOf(
        "exportedPhotoAssetIds" to emptyList<String>(),
        "failures" to request.groups.flatMap { group ->
            group.assetIds.map { failure(it, "userCancelled") }
        },
    )

    private fun permissionDeniedResult(request: CollectionRequest): Map<String, Any> = mapOf(
        "exportedPhotoAssetIds" to emptyList<String>(),
        "failures" to request.groups.flatMap { group ->
            group.assetIds.map { failure(it, "permissionDenied") }
        },
    )

    private fun emptyResult(): Map<String, Any> = mapOf(
        "exportedPhotoAssetIds" to emptyList<String>(),
        "failures" to emptyList<Map<String, String>>(),
    )

    private fun failure(assetId: String, reason: String) =
        mapOf("photoAssetId" to assetId, "reason" to reason)

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() = detachActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() = detachActivity()

    private fun detachActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
    }

    private data class CollectionGroup(val name: String, val assetIds: List<String>)
    private data class CollectionRequest(
        val containerName: String,
        val destination: String,
        val groups: List<CollectionGroup>,
    )
    private data class PendingExport(
        val request: CollectionRequest,
        val result: MethodChannel.Result,
    )

    private companion object {
        const val CHANNEL_NAME = "dev.templates.addons/android_media_store"
        const val WRITE_REQUEST_CODE = 7241
    }
}
