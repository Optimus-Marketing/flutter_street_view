Pod::Spec.new do |s|
  s.name             = 'flutter_google_street_view'
  s.version          = '1.0.0'
  s.summary          = 'A flutter plugin of google street view in iOS and Android applications.'
  s.description      = <<-DESC
A flutter plugin of google street view in iOS and Android applications.
                       DESC
  s.homepage         = 'https://github.com/Optimus-Marketing/flutter_street_view'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ZYZ' => 'pk279700197@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'GoogleMaps'
  s.static_framework = true
  s.platform = :ios, '15.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
