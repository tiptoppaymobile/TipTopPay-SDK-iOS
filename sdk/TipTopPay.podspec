#
#  Be sure to run `pod spec lint SDK-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "TipTopPay"
  spec.version      = "1.0.11"
  spec.summary      = "Core library that allows you to use internet acquiring from TipTopPay in your app"
  spec.description  = "Core library that allows you to use internet acquiring from TipTopPay in your app!"

  spec.homepage     = "https://tiptoppay.inc/"

  spec.license      = "{ :type => 'Apache 2.0' }"

  spec.author       = { "Anton Ignatov" => "a.ignatov@tiptoppay.inc" }
	
  spec.platform     = :ios
  spec.ios.deployment_target = "13.0"

  spec.source       = { :git => "https://gitlab.com/tiptoppay/mobile/tiptoppay-sdk-ios.git", :tag => "#{spec.version}" }
  spec.source_files  = 'Sources/**/*.swift'

  spec.resource_bundles = { 'TipTopPaySDK' => ['Resources/**/*.{txt,json,png,jpeg,jpg,storyboard,xib,xcassets,strings}']} 
  
  spec.requires_arc = true

  spec.dependency 'TipTopPayNetworking'  

  spec.swift_version = '5.0'

end
