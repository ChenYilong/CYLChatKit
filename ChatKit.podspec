Pod::Spec.new do |s|
  s.name         = "ChatKit"
  s.version      = "2.3.11"
  s.summary      = "Customizable iOS chat UI framework with messaging and conversation management"
  s.description  = "[EN]An iOS chat UI framework with conversation lists, text, image, audio, video, and location messages, plus contact management.  [CN]为 iOS 应用提供可定制的聊天界面、会话管理和多类型消息支持。"
  s.homepage     = "https://github.com/ChenYilong/CYLChatKit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "ChenYilong" => "luohanchenyilong@163.com" }
  s.platform     = :ios, '15.0'
  s.frameworks   = 'Foundation', 'CoreGraphics', 'UIKit', 'MobileCoreServices', 'AVFoundation', 'CoreLocation', 'MediaPlayer', 'CoreMedia', 'CoreText', 'AudioToolbox','MapKit','ImageIO','SystemConfiguration','CFNetwork','QuartzCore','Security','CoreTelephony'
  s.source       = { :git => "https://github.com/ChenYilong/CYLChatKit.git", :tag => s.version.to_s }
  s.source_files  = 'ChatKit', 'ChatKit/**/*.{h,m}'
  s.vendored_frameworks = 'ChatKit/Class/Tool/Vendor/VoiceLib/lame.framework'
  s.resources    = 'ChatKit/Class/Resources/*', 'ChatKit/**/*.xib'

  s.requires_arc = true
  s.dependency "AVOSCloud" , "~> 11.5.1"
  s.dependency "AVOSCloudIM", "~> 11.5.1"
  s.dependency "MJRefresh"
  s.dependency "Masonry" , "~> 1.0.1"
  s.dependency "SDWebImage" , "~> 3.8.0"
  s.dependency "FMDB" , "~> 2.6.2"
  s.dependency "pop", "~> 1.0.9"
  #s.dependency "UITableView+FDTemplateLayoutCell" , "~> 1.5.beta"
  s.dependency "UITableView+FDTemplateLayoutCell"
  s.dependency "FDStackView" , "~> 1.0"
  s.dependency "DACircularProgress" , "~> 2.3.1"
  s.dependency "MLLabel" , "~> 1.10.5"
  s.dependency "MWPhotoBrowser", "~> 2.1.2"
  s.dependency "CYLDeallocBlockExecutor", "~> 1.1.2"

end
