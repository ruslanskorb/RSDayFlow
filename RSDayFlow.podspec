Pod::Spec.new do |s|
  s.name         = 'RSDayFlow'
  s.version      = '0.7.2'
  s.summary      = 'iOS 7 Calendar with Infinite Scrolling.'
  s.homepage     = 'https://github.com/maltebargholz/RSDayFlow'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'Evadne Wu' => 'ev@radi.ws', 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' ,'Malte Bargholz' => 'maltebargholz@gmail.com'}
  s.source       = { :git => 'https://github.com/maltebargholz/RSDayFlow.git', :tag => '0.7.2' }
  s.platform     = :ios, '7.0'
  s.source_files = 'RSDayFlow'
  s.frameworks = 'QuartzCore', 'UIKit'
  s.requires_arc = true
end
