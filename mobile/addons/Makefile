PACKAGE_DIRS = \
	local_storage/shared_preferences_storage \
	photo_library/photo_manager_gateway \
	geocoding/android_geocoding_gateway \
	geocoding/ios_geocoding_gateway \
	media_collection/android_media_store_gateway \
	media_collection/ios_photo_kit_gateway

TEST_PACKAGE_DIRS = \
	local_storage/shared_preferences_storage \
	geocoding/android_geocoding_gateway \
	geocoding/ios_geocoding_gateway \
	media_collection/android_media_store_gateway \
	media_collection/ios_photo_kit_gateway

.PHONY: pub-get format analyze test

pub-get:
	@for package_dir in $(PACKAGE_DIRS); do \
		(cd $$package_dir && flutter pub get) || exit 1; \
	done

format:
	@for package_dir in $(PACKAGE_DIRS); do \
		if [ -d $$package_dir/test ]; then \
			(cd $$package_dir && dart format lib test) || exit 1; \
		else \
			(cd $$package_dir && dart format lib) || exit 1; \
		fi; \
	done

analyze:
	@for package_dir in $(PACKAGE_DIRS); do \
		(cd $$package_dir && flutter analyze) || exit 1; \
	done

test:
	@for package_dir in $(TEST_PACKAGE_DIRS); do \
		(cd $$package_dir && flutter test) || exit 1; \
	done
