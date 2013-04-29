Pod::Spec.new do |s|
  s.name         = "DayFlow"
  s.version      = "0.0.2"
  s.summary      = "Strollable Date Picker."
  s.homepage     = "http://github.com/evadne/DayFlow"
  s.license      = 'MIT'
  s.author       = { "Evadne Wu" => "ev@radi.ws" }
  s.source       = { :git => "http://github.com/evadne/DayFlow.git", :tag => "0.0.2" }
  s.platform     = :ios, '6.0'
  s.source_files = 'DayFlow', 'DayFlow/**/*.{h,m}'
  s.exclude_files = 'DayFlow/Exclude'
  s.frameworks = 'QuartzCore', 'UIKit'
  s.requires_arc = true
end
