Pod::Spec.new do |spec|

spec.name         = "ZHPlayer"
spec.version      = "0.9.0"
spec.summary      = "A video player form iOS native API."

spec.description  = <<-DESC
							"A video player form iOS native API."
						DESC
spec.homepage     = "https://github.com/cherk201/ZHPlayer.git"
spec.license      = "MIT"
spec.author       = { "Arex" => "arex0207@aliyun.com" }
# spec.platform     = :ios
spec.ios.deployment_target = "10.0"

spec.platform     = :ios, "10.0"
spec.source       = { :git => "https://github.com/cherk201/ZHPlayer.git", :tag => "#{spec.version}" }
spec.source_files = "PlayerDemo/*.{swift}"

spec.swift_version = '5.3'

spec.dependency "SnapKit", "~> 4.2.0"

end
