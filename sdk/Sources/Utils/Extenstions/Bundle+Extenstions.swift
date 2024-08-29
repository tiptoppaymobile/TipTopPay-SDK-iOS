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
        let bundle = Bundle.init(for: PaymentForm.self)
        let bundleUrl = bundle.url(forResource: "TipTopPaySDK", withExtension: "bundle")
        return Bundle.init(url: bundleUrl!)!
    }
    
    class var cocoapods: Bundle? {
        return Bundle(identifier: "org.cocoapods.TipTopPaySDK")
    }
}


