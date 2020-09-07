#
#  Be sure to run `pod spec lint AKPhotoPicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#ß

Pod::Spec.new do |spec|

spec.name         = "AKPhotoPicker"
spec.version      = "1.0.1"
spec.summary      = "AKPhotoPicker is a multi-image picker. Using this we can able to pick and preview the image before sending it to remote"
spec.description  = <<-DESC
AKPhotoPicker is a multi-image picker. Using this we can able to pick and preview the image before sending it to remote. The is WhatsApp like multi-image picker
DESC
spec.homepage     = "http://www.github.com/karthianandhanios/AKPhotoPicker.git"
spec.license      = 'MIT'
spec.author             = { "karthiAnandhan" => "karthianandhanit@gmail.com" }
spec.authors            = { "KarthivAnandhan" => "karthianandhanit@gmail.com" }
spec.social_media_url   = "https://twitter.com/karthiAnandhan"
spec.platform     = :ios, "11.0"
spec.swift_version = "4.2"
spec.source       = { :git => "https://github.com/karthianandhanios/AKPhotoPicker.git", :tag => "1.0.1" }
spec.source_files  = "AKPhotoPicker"
spec.exclude_files = "Classes/Exclude"
# spec.public_header_files = "Classes/**/*.h"
# spec.resource  = "icon.png"
# spec.resources = "Resources/*.png"
spec.resources = "AKPhotoPicker/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

end
