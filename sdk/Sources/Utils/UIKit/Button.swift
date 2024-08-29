//
//  Button.swift
//  sdk
//
//  Created by TipTopPay on 17.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit

class Button: UIButton {
    var onAction: (()->())?
    
    @IBInspectable var borderWidth : CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth;
        }
    }
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var cornerRadius : CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    func setAlpha(_ alpha: CGFloat) {
        self.alpha = alpha
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(onAction(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(onAction(_:)), for: .touchUpInside)
    }
    
    @objc func onAction(_ sender: Any) {
        if self.onAction != nil {
            self.onAction!()
        }
    }
}
