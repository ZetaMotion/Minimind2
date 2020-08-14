Pod::Spec.new do |s|
  s.name                      = "Minimind2"
  s.version                   = "1.0.0"
  s.summary                   = "Minimind2"
  s.homepage                  = "https://github.com/HuyPhan/Minimind2"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Huy Phan" => "phan@zetamotion.com" }
  s.source                    = { :git => "https://github.com/HuyPhan/Minimind2.git", :tag => s.version.to_s }
  s.swift_version             = "5.1"
  s.ios.deployment_target     = "8.0"
  s.tvos.deployment_target    = "9.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target     = "10.10"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"
end
