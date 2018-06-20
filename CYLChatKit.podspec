Pod::Spec.new do |s|
  s.name         = "CYLChatKit"
  s.version      = "2.1.9"
  s.summary      = "An IM App Framework, support sending text, pictures, audio, video, location messaging, managing address book, more interesting features."
  s.homepage     = "https://github.com/ChenYilong/CYLChatKit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "ElonChan" => "luohanchenyilong@163.com" }
  s.platform     = :ios, '8.0'
  s.frameworks   = 'Foundation', 'CoreGraphics', 'UIKit', 'MobileCoreServices', 'AVFoundation', 'CoreLocation', 'MediaPlayer', 'CoreMedia', 'CoreText', 'AudioToolbox','MapKit','ImageIO','SystemConfiguration','CFNetwork','QuartzCore','Security','CoreTelephony'
  s.source       = { :git => "https://github.com/ChenYilong/CYLChatKit.git", :tag => s.version.to_s }
  s.source_files  = 'ChatKit', 'ChatKit/**/*.{h,m}'
  s.vendored_frameworks = 'ChatKit/Class/Tool/Vendor/VoiceLib/lame.framework'
  s.resources    = 'ChatKit/Class/Resources/*', 'ChatKit/**/*.xib'

  s.requires_arc = true
  s.dependency "AVOSCloud" , "~> 11.0.0"
  s.dependency "AVOSCloudIM", "~> 11.0.0"
  s.dependency "MJRefresh" , "~> 3.1.9"
  s.dependency "Masonry" , "~> 1.0.1"
  s.dependency "SDWebImage" , "~> 4.4.1"
  s.dependency "FMDB" , "~> 2.6.2"
  s.dependency "pop", "~> 1.0.9"
  s.dependency "UITableView+FDTemplateLayoutCell" , "~> 1.5.beta"
  s.dependency "FDStackView" , "~> 1.0"
  s.dependency "DACircularProgress" , "~> 2.3.1"
  s.dependency "MLLabel" , "~> 1.10.5"
  s.dependency "CYLDeallocBlockExecutor", "~> 1.2.0"
  s.dependency 'MBProgressHUD', '~> 1.1.0'

end
