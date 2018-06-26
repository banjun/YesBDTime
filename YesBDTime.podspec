Pod::Spec.new do |s|
  s.name             = 'YesBDTime'
  s.version          = '0.2.0'
  s.summary          = 'Get current time of Blu-ray Player'
  s.description      = <<-DESC
  Get current time of Blu-ray Player by M@GIC☆
                       DESC
  s.homepage         = 'https://github.com/banjun/YesBDTime'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'banjun' => 'banjun@gmail.com' }
  s.source           = { :git => 'https://github.com/banjun/YesBDTime.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/banjun'
  s.platform = :osx
  s.osx.deployment_target = "10.13"
  s.source_files = ['YesBDTime/Classes/**/*', 'YesBDTime/**/*.mlmodel']
  s.swift_version = '4.0'
end
