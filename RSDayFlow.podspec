Pod::Spec.new do |s|
  s.name          = 'RSDayFlow'
  s.version       = '1.6.1'
  s.summary       = 'iOS 7 Calendar with Infinite Scrolling.'
  s.homepage      = 'https://github.com/ruslanskorb/RSDayFlow'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.authors       = { 'Evadne Wu' => 'ev@radi.ws', 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' }
  s.source        = { :git => 'https://github.com/AntonBelousov/RSDayFlow.git', :tag => s.version.to_s }
  s.platform      = :ios, '7.0'
  s.module_map    = 'RSDayFlow/RSDayFlow.modulemap'
  s.source_files  = 'RSDayFlow/*.{h,m}'
  s.frameworks    = 'QuartzCore', 'UIKit'
  s.requires_arc  = true
end
