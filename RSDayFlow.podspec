Pod::Spec.new do |s|
  s.name          = 'RSDayFlow'
  s.version       = '2.0.0'
  s.summary       = 'iOS 12+ Calendar with Infinite Scrolling.'
  s.homepage      = 'https://github.com/ruslanskorb/RSDayFlow'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.authors       = { 'Evadne Wu' => 'ev@radi.ws', 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' }
  s.source        = { :git => 'https://github.com/ruslanskorb/RSDayFlow.git', :tag => s.version.to_s }
  s.platform      = :ios, '12.0'
  s.module_map    = 'RSDayFlow/RSDayFlow.modulemap'
  s.source_files  = 'RSDayFlow/*.{h,m}'
  s.frameworks    = 'QuartzCore', 'UIKit'
  s.requires_arc  = true
end
