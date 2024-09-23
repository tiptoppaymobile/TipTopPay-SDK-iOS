//
//  ApiErrors.swift
//  sdk
//
//  Created by TipTopPay on 01.12.2022.
//  Copyright © 2022 TipTopPay. All rights reserved.
//

import Foundation
public class ApiError {
    
    static let errors = [
       
        "3001": "ttpsdk_error_3001".localized,
        "3002": "ttpsdk_error_3002".localized,
        "3003": "ttpsdk_error_3003".localized,
        "3004": "ttpsdk_error_3004".localized,
        "3005": "ttpsdk_error_3005".localized,
        "3006": "ttpsdk_error_3006".localized,
        "3007": "ttpsdk_error_3007".localized,
        "3008": "ttpsdk_error_3008".localized,
        "5001": "ttpsdk_error_5001".localized,
        "5005": "ttpsdk_error_5005".localized,
        "5006": "ttpsdk_error_5006".localized,
        "5012": "ttpsdk_error_5012".localized,
        "5013": "ttpsdk_error_5013".localized,
        "5030": "ttpsdk_error_5030".localized,
        "5031": "ttpsdk_error_5031".localized,
        "5034": "ttpsdk_error_5034".localized,
        "5041": "ttpsdk_error_5041".localized,
        "5043": "ttpsdk_error_5043".localized,
        "5051": "ttpsdk_error_5051".localized,
        "5054": "ttpsdk_error_5054".localized,
        "5057": "ttpsdk_error_5057".localized,
        "5061": "ttpsdk_error_5061".localized,
        "5065": "ttpsdk_error_5065".localized,
        "5082": "ttpsdk_error_5082".localized,
        "5091": "ttpsdk_error_5091".localized,
        "5092": "ttpsdk_error_5092".localized,
        "5096": "ttpsdk_error_5096".localized,
        "5204": "ttpsdk_error_5204".localized,
        "5206": "ttpsdk_error_5206".localized,
        "5207": "ttpsdk_error_5207".localized,
        "5300": "ttpsdk_error_5300".localized,
        "3001_extra": "ttpsdk_error_3001_extra".localized,
        "3002_extra": "ttpsdk_error_3002_extra".localized,
        "3003_extra": "ttpsdk_error_3003_extra".localized,
        "3004_extra": "ttpsdk_error_3004_extra".localized,
        "3005_extra": "ttpsdk_error_3005_extra".localized,
        "3006_extra": "ttpsdk_error_3006_extra".localized,
        "3007_extra": "ttpsdk_error_3007_extra".localized,
        "3008_extra": "ttpsdk_error_3008_extra".localized,
        "5001_extra": "ttpsdk_error_5001_extra".localized,
        "5005_extra": "ttpsdk_error_5005_extra".localized,
        "5006_extra": "ttpsdk_error_5006_extra".localized,
        "5012_extra": "ttpsdk_error_5012_extra".localized,
        "5013_extra": "ttpsdk_error_5013_extra".localized,
        "5030_extra": "ttpsdk_error_5030_extra".localized,
        "5031_extra": "ttpsdk_error_5031_extra".localized,
        "5034_extra": "ttpsdk_error_5034_extra".localized,
        "5041_extra": "ttpsdk_error_5041_extra".localized,
        "5043_extra": "ttpsdk_error_5043_extra".localized,
        "5051_extra": "",
        "5054_extra": "ttpsdk_error_5054_extra".localized,
        "5057_extra": "ttpsdk_error_5057_extra".localized,
        "5061_extra": "ttpsdk_error_5061_extra".localized,
        "5065_extra": "ttpsdk_error_5065_extra".localized,
        "5082_extra": "ttpsdk_error_5082_extra".localized,
        "5091_extra": "ttpsdk_error_5091_extra".localized,
        "5092_extra": "ttpsdk_error_5092_extra".localized,
        "5096_extra": "ttpsdk_error_5096_extra".localized,
        "5204_extra": "ttpsdk_error_5204_extra".localized,
        "5206_extra": "ttpsdk_error_5206_extra".localized,
        "5207_extra": "ttpsdk_error_5207_extra".localized,
        "5300_extra": "ttpsdk_error_5300_extra".localized
    ]
    
    public static func getFullErrorDescription(code: String) -> String {
        
        let error = "\(getErrorDescription(code: code))#\(getErrorDescriptionExtra(code: code))"
        
        return error
    }
    
    static func getErrorDescription(code: String) -> String {
        
        let description: String = errors[code] ?? "ttpsdk_error_1".localized
        return description
    }
    
    static func getErrorDescriptionExtra(code: String) -> String {
        
        let description: String = errors[code + "_extra"] ?? "ttpsdk_error_2".localized
        return description
    }
}


