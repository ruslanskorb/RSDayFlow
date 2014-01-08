Pod::Spec.new do |s|
  s.name         = 'RSDayFlow'
  s.version      = '0.1.0'
  s.summary      = 'Scrollable iOS 7 Date Picker.'
  s.homepage     = 'http://github.com/ruslanskorb/RSDayFlow'
  s.license      = 'MIT'
  s.authors      = { 'Evadne Wu' => 'ev@radi.ws', 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' }
  s.source       = { :git => 'http://github.com/ruslanskorb/RSDayFlow.git', :tag => '0.1.0' }
  s.platform     = :ios, '7.0'
  s.source_files = 'RSDayFlow', 'RSDayFlow/**/*.{h,m}'
  s.exclude_files = 'RSDayFlow/Exclude'
  s.frameworks = 'QuartzCore', 'UIKit'
  s.requires_arc = true
end
