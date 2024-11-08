//
//  UIImage+Assets.swift
//  sdk
//
//  Created by TipTopPay on 24.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import UIKit

extension UIImage {
    public class func named(_ name: String) -> UIImage {
        
        let image2 = UIImage.init(named: name, in: Bundle.mainSdk, compatibleWith: nil)
        if image2 != nil {
            return image2!
        }
        return UIImage()
    }
    
    public class var iconProgress: UIImage {
        return self.named("ic_progress")
    }
    
    public class var iconSuccess: UIImage {
        return self.named("ic_success")
    }
    
    public class var iconFailed: UIImage {
        return self.named("ic_failed")
    }
    
    public class var iconUnselected: UIImage {
        return self.named("ic_checkbox_unselected")
    }
    
    public class var iconSelected: UIImage {
        return self.named("ic_checkbox_selected")
    }
    
    public class var icn_attention: UIImage {
        return self.named("icn_attention")
    }
    
    public class var ic_secured_by_ttp: UIImage {
        return self.named("ic_secured_by_ttp")
    }
    
    public class var ic_oxxo: UIImage {
        return self.named("icn_oxxo")
    }
    
    public class var ic_pharma: UIImage {
        return self.named("icn_pharma")
    }
    
    public class var ic_seven_eleven_pharma: UIImage {
        return self.named("icn_seven_eleven_pharma")
    }
    
    public class var ic_seven_eleven: UIImage {
        return self.named("icn_seven_eleven")
    }
    
    public class var ic_spei: UIImage {
        return self.named("icn_spei")
    }
    
    public class var ic_wallmart: UIImage {
        return self.named("icn_wallmart")
    }
    
    public class var ic_copy_spei_image: UIImage {
        return self.named("icn_copy_spei")
    }
    
    public class var ic_send_btn_logo: UIImage {
        return self.named("icn_send_btn_logo")
    }
}

extension UIImageView {
    
    var colorRenderForImage:UIColor {
        get {return self.tintColor}
        set {
            self.image = self.image?.withRenderingMode(.alwaysTemplate)
            self.tintColor = newValue
        }
    }
}
