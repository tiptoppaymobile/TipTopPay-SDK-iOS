//
//  TipTopPayConfiguration.swift
//  sdk
//
//  Created by TipTopPay on 08.10.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

public class TipTopPayConfiguration {
    let publicId: String
    let paymentData: TipTopPayData
    let paymentDelegate: TipTopPayDelegateImpl
    let paymentUIDelegate: TipTopPayUIDelegateImpl
    let scanner: PaymentCardScanner?
    let requireEmail: Bool
    let useDualMessagePayment: Bool
    let disableApplePay: Bool
    let apiUrl: String
    let customListBanks: Bool

    public init(publicId: String, paymentData: TipTopPayData, delegate: TipTopPayDelegate?, uiDelegate: TipTopPayUIDelegate?, scanner: PaymentCardScanner?,
                requireEmail: Bool = false, useDualMessagePayment: Bool = false, disableApplePay: Bool = false, apiUrl: String = "https://api.tiptoppay.kz/", customListBanks: Bool = false) {
        self.publicId = publicId
        self.paymentData = paymentData
        self.paymentDelegate = TipTopPayDelegateImpl.init(delegate: delegate)
        self.paymentUIDelegate = TipTopPayUIDelegateImpl.init(delegate: uiDelegate)
        self.scanner = scanner
        self.requireEmail = requireEmail
        self.useDualMessagePayment = useDualMessagePayment
        self.disableApplePay = disableApplePay
        self.apiUrl = apiUrl
        self.customListBanks = customListBanks
    }
}
