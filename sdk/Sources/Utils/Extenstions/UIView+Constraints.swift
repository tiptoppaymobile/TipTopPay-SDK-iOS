//
//  UIView+Constraints.swift
//  sdk
//
//  Created by TipTopPay on 17.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit

extension UIView {
    func bindFrameToSuperviewBounds(){
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
    
    func addXib(_ name: String? = nil) {
        #if SWIFT_PACKAGE
        let nibBundle = Bundle.module
        #else
        guard let nibBundle = Bundle(identifier: "org.cocoapods.TipTopPaySDK") else {
            return
        }
        #endif
        
        let xibName = name ?? String(describing: Self.self)
        
        let views = nibBundle.loadNibNamed(xibName, owner: self)
        if let view = views?.first as? UIView  {
            view.frame = bounds
            addSubview(view)
        }
    }
    
    func fullConstraint(top:CGFloat! = 0, bottom:CGFloat! = 0, leading:CGFloat! = 0, trailing:CGFloat! = 0) {
            guard let view = self.superview else { return }
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom),
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing),
            ])
        }
}
