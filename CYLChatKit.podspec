Pod::Spec.new do |s|
  s.name         = "CYLChatKit"
  s.version      = "2.3.11"
  s.summary      = "Customizable iOS chat UI framework with messaging and conversation management"
  s.description  = "[EN]An iOS chat UI framework with conversation lists, text, image, audio, video, and location messages, plus contact management.  [CN]为 iOS 应用提供可定制的聊天界面、会话管理和多类型消息支持。"
  s.homepage     = "https://github.com/ChenYilong/CYLChatKit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "ChenYilong" => "luohanchenyilong@163.com" }
  s.social_media_url = 'http://weibo.com/luohanchenyilong/'
  s.platform     = :ios, '15.0'
  s.swift_versions = ['5.0']
  s.source       = { :git => "https://github.com/ChenYilong/CYLChatKit.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.default_subspec = 'Core'
  s.static_framework = true

  s.subspec 'Core' do |core|
    core.source_files = 'ChatKit', 'ChatKit/**/*.{h,m}'
    core.public_header_files = 'ChatKit/**/*.h'
    # iOS 7 backport of UITableViewRowAction. It refuses to compile when the minimum deployment target is iOS 8 or
    # later (#error), and UIKit provides the class on every supported iOS version.
    core.exclude_files = 'ChatKit/Class/Tool/Vendor/CYLTableViewRowAction/UITableViewRowAction.m'
    core.vendored_frameworks = 'ChatKit/Class/Tool/Vendor/VoiceLib/lame.framework'
    # lame.framework has device slices (armv7, armv7s, arm64) and Intel simulator slices (i386, x86_64), but no arm64
    # simulator slice, so simulator builds link x86_64 only. Remove this once lame ships as an XCFramework.
    core.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    core.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    core.resources = 'ChatKit/Class/Resources/*', 'ChatKit/**/*.xib'
    core.frameworks = 'Foundation', 'CoreGraphics', 'UIKit', 'MobileCoreServices', 'AVFoundation', 'CoreLocation', 'MediaPlayer', 'CoreMedia', 'CoreText', 'AudioToolbox', 'MapKit', 'ImageIO', 'SystemConfiguration', 'CFNetwork', 'QuartzCore', 'Security', 'CoreTelephony'

    # ChatKit is UI only and does not depend on an IM SDK. Apps implement `LCCKIMProvider`;
    # the demo app (ChatKit-OC) contains the LeanCloud implementation and its AVOSCloud dependencies.
    core.dependency "MJRefresh"
    core.dependency "Masonry", "~> 1.0.1"
    core.dependency "SDWebImage", "~> 3.8.0"
    core.dependency "FMDB", "~> 2.6.2"
    core.dependency "pop", "~> 1.0.9"
    core.dependency "UITableView+FDTemplateLayoutCell"
    core.dependency "FDStackView", "~> 1.0"
    core.dependency "DACircularProgress", "~> 2.3.1"
    core.dependency "MLLabel", "~> 1.10.5"
    core.dependency "MWPhotoBrowser", "~> 2.1.2"
    core.dependency "CYLDeallocBlockExecutor", "~> 1.2.0"
    core.dependency "CYLTableViewPlaceHolder", "~> 1.1.0"
  end

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LIBTOOLFLAGS' => '-no_warning_for_no_symbols',
    'WARNING_CFLAGS' => [
      '-Werror=undeclared-selector',
      '-Werror=incomplete-implementation'
    ]
  }

end
