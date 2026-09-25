Pod::Spec.new do |spec|
  spec.name = 'device_haptics'
  spec.version = '0.1.0'
  spec.summary = 'Device haptics APIs for the Device Playground.'
  spec.description = 'Provides Flutter, Core Haptics, and Android vibration APIs.'
  spec.homepage = 'https://example.com/device-haptics'
  spec.license = { :type => 'Proprietary', :text => 'Internal project package.' }
  spec.author = { 'Device Playground' => 'noreply@example.com' }
  spec.source = { :path => '.' }
  spec.source_files = 'device_haptics/Sources/device_haptics/**/*'
  spec.dependency 'Flutter'
  spec.platform = :ios, '15.0'
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  spec.swift_version = '5.0'
end
