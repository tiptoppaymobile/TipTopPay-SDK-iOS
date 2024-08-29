#
#  Be sure to run `pod spec lint SDK-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "TipTopPayNetworking"
  spec.version      = "1.0.0"
  spec.summary      = "Networking layer for TipTopPay SDK's"
  spec.description  = "Networking layer for TipTopPay SDK's"

  spec.homepage     = "https://tiptoppay.inc/"

  spec.license      = "{ :type => 'Apache 2.0' }"

  spec.author       = { "Anton Ignatov" => "a.ignatov@tiptoppay.inc" }
	
  spec.platform     = :ios
  spec.ios.deployment_target = "13.0"

  spec.source       = { :git => "https://gitlab.com/tiptoppay/mobile/tiptoppay-sdk-ios.git", :tag => "#{spec.version}" }
  spec.source_files  = 'networking/source/**/*.swift'

  spec.requires_arc = true

  spec.swift_version = '5.0'
  
end
