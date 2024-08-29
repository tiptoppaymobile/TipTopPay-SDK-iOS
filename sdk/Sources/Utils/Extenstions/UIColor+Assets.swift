//
//  UIColor+Assets.swift
//  sdk
//
//  Created by TipTopPay on 18.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit

extension UIColor {
    class var custom: UICustomColor.Type { return UICustomColor.self }
    
    class UICustomColor {
        class var white: UIColor {
            return UIColor.white
        }
    }
    
    public class var mainText: UIColor {
        return color(named: "color_text_main")
    }
    
    public class var mainTextPlaceholder: UIColor {
        return color(named: "color_text_placeholder")
    }
    
    public class var mainBlue: UIColor! {
        return color(named: "color_blue")
    }
    
    public class var border: UIColor! {
        return color(named: "color_border")
    }
    
    public class var colorTextButton: UIColor! {
        return color(named: "color_text_button")
    }
    
    public class var errorBorder: UIColor {
        return color(named: "color_red")
    }
    
    public class var blackColor: UIColor {
        return color(named: "color_black")
    }
    
    public class var whiteColor: UIColor {
        return UIColor.white
    }
    
    public class var colorAlertView: UIColor {
        return color(named: "color_alert_view")
    }
    
    public class var colorLoader: UIColor {
        return color(named: "color_loader")
    }
    
    public class var colorProgressText: UIColor {
        return color(named: "color_progress_text")
    }
    
    private class func color(named colorName: String) -> UIColor! {
        return UIColor.init(named: colorName, in: Bundle.mainSdk, compatibleWith: .none)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}
