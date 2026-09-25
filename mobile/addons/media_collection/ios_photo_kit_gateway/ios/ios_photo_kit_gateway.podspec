Pod::Spec.new do |s|
  s.name             = 'ios_photo_kit_gateway'
  s.version          = '0.1.0'
  s.summary          = 'iOS PhotoKit collection operations.'
  s.description      = <<-DESC
PhotoKit-backed media collection operations for Flutter.
                       DESC
  s.homepage         = 'https://example.invalid/mobile-addons'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mobile Add-ons' => 'dev@example.invalid' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'
  s.swift_version = '5.0'
end
