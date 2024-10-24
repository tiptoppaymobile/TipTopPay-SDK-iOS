//
//  TipTopPayHTTPResource.swift
//  sdk
//
//  Created by TipTopPay on 02.07.2021.
//  Copyright © 2021 TipTopPay. All rights reserved.
//

import Foundation

enum TipTopPayHTTPResource: String {
    case charge = "payments/cards/charge"
    case auth = "payments/cards/auth"
    case post3ds = "payments/ThreeDSCallback"
    case installmentsCalculateSumByPeriod = "installments/calculate/sum-by-period"
    case altPayCash = "payments/altpay/pay"
    case binInfo = "bins/info"
    
    func asUrl(apiUrl: String) -> String {
        return apiUrl.appending(self.rawValue)
    }
}
