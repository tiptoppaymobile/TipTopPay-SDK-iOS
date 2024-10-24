//
//  CGFloat+Extensions.swift
//  sdk
//
//  Created by TipTopPay on 13.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
