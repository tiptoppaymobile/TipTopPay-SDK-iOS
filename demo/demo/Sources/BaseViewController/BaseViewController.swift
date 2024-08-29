//
//  BaseViewController.swift
//  demo
//
//  Created by TipTopPay on 15.10.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

class BaseViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
}
