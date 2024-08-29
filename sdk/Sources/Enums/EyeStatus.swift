//
//  EyeStatus.swift
//  sdk
//
//  Created by TipTopPay on 19.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation
import UIKit

enum EyeStatus: String {
    case open = "icn_eye_open"
    case closed = "icn_eye_closed"
    
    func toString() -> String {
        return self.rawValue
    }
    
    var image: UIImage? {
        switch self {
        case .open:
            return UIImage.named(rawValue)
        case .closed:
            return UIImage.named(rawValue)
        }
    }
}
