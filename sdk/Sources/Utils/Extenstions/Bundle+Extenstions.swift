//
//  Bundle+Extenstions.swift
//  sdk
//
//  Created by TipTopPay on 16.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit

extension Bundle {
    
    class var mainSdk: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let fallbackBundle = Bundle(for: PaymentForm.self)
        
        if let bundleUrl = fallbackBundle.url(forResource: "TipTopPaySDK", withExtension: "bundle"),
           let podBundle = Bundle(url: bundleUrl) {
            return podBundle
        } else {
            return fallbackBundle
        }
        #endif
    }
    
    class var cocoapods: Bundle? {
        return Bundle(identifier: "org.cocoapods.TipTopPaySDK")
    }
 
}


