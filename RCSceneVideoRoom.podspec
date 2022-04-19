
Pod::Spec.new do |s|
  
  # 1 - Info
  s.name             = 'RCSceneVideoRoom'
  s.version          = '0.0.2.3'
  s.summary          = 'Scene Video Room'
  s.description      = "Scene Video Room module"
  s.homepage         = 'https://github.com/rongcloud'
  s.license      = { :type => "Copyright", :text => "Copyright 2022 RongCloud" }
  s.author           = { 'shaoshuai' => 'shaoshuai@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/rongcloud-community/rongcloud-scene-video-room-ios.git', :tag => s.version.to_s }
  
  # 2 - Version
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.static_framework = true
  
  # 3 - config
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'VALID_ARCHS' => 'arm64 x86_64',
    'SWIFT_COMPILATION_MODE' => 'Incremental',
    'OTHER_SWIFT_FLAGS' => '-Xfrontend -enable-dynamic-replacement-chaining',
  }
  
  # 4 - source
  s.source_files = 'RCSceneVideoRoom/Classes/**/*'
  
  # 5 - dependency
  s.dependency 'Pulsator'
  s.dependency 'MJRefresh'
  s.dependency 'SDWebImage'
  s.dependency 'XCoordinator'
  s.dependency 'IQKeyboardManager'
  
  # >= 0.0.2.3
  s.dependency 'RCSceneRoom/RCSceneRoom'
  s.dependency 'RCSceneRoom/RCSceneMusic'
  s.dependency 'RCSceneRoom/RCSceneGift'
  s.dependency 'RCSceneRoom/RCSceneRoomSetting'
  
  s.dependency 'RCLiveVideoLib'
  
end
