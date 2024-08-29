//
//  ObserverKeys.swift
//  sdk
//
//  Created by TipTopPay on 16.08.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation

enum ObserverKeys: String {
    case payStatus = "StatusPayObserver"
    case networkConnectStatus = "NetworkConnectStatusObserver"
    
    var key: NSNotification.Name {
        return NSNotification.Name(rawValue: rawValue)
    }
}
