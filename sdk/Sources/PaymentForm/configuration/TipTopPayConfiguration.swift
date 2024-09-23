//
//  TipTopPayConfiguration.swift
//  sdk
//
//  Created by TipTopPay on 08.10.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

public enum Region: String {
    case MX = "https://api.tiptoppay.mx/"
    case KZ = "https://api.tiptoppay.kz/"
    
    func getApiUrl() -> String {
        return self.rawValue
    }
}

public class TipTopPayConfiguration {
    let publicId: String
    let paymentData: TipTopPayData
    let paymentDelegate: TipTopPayDelegateImpl
    let paymentUIDelegate: TipTopPayUIDelegateImpl
    let scanner: PaymentCardScanner?
    let requireEmail: Bool
    let useDualMessagePayment: Bool
    let disableApplePay: Bool
    var apiUrl: String?
    let region: Region

    public init(region: Region, publicId: String, paymentData: TipTopPayData, delegate: TipTopPayDelegate?, uiDelegate: TipTopPayUIDelegate?, scanner: PaymentCardScanner?,
                requireEmail: Bool = false, useDualMessagePayment: Bool = false, disableApplePay: Bool = false, apiUrl: String?, customListBanks: Bool = false) {
        self.publicId = publicId
        self.paymentData = paymentData
        self.paymentDelegate = TipTopPayDelegateImpl.init(delegate: delegate)
        self.paymentUIDelegate = TipTopPayUIDelegateImpl.init(delegate: uiDelegate)
        self.scanner = scanner
        self.requireEmail = requireEmail
        self.useDualMessagePayment = useDualMessagePayment
        self.disableApplePay = disableApplePay
        self.region = region
        self.apiUrl = apiUrl
        
        if apiUrl.isNilOrEmpty {
            self.apiUrl = self.region.getApiUrl()
        } else {
            self.apiUrl = apiUrl
        }
    }
}
