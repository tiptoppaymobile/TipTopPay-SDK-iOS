//
//  TipTopPayDelegate.swift
//  sdk
//
//  Created by TipTopPay on 08.10.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

public protocol TipTopPayDelegate: AnyObject {
    func onPaymentFinished(_ transactionId: Int64?)
    func onPaymentFailed(_ errorMessage: String?)
}

public protocol TipTopPayUIDelegate: AnyObject {
    func paymentFormWillDisplay()
    func paymentFormDidDisplay()
    func paymentFormWillHide()
    func paymentFormDidHide()
}

internal class TipTopPayDelegateImpl {
    weak var delegate: TipTopPayDelegate?
    
    init(delegate: TipTopPayDelegate?) {
        self.delegate = delegate
    }
    
    func paymentFinished(_ transaction: Transaction?){
        self.delegate?.onPaymentFinished(transaction?.transactionId)
    }
    
    func paymentFailed(_ errorMessage: String?) {
        self.delegate?.onPaymentFailed(errorMessage)
    }
}

internal class TipTopPayUIDelegateImpl {
    weak var delegate: TipTopPayUIDelegate?
    
    init(delegate: TipTopPayUIDelegate?) {
        self.delegate = delegate
    }
    
    func paymentFormWillDisplay() {
        self.delegate?.paymentFormWillDisplay()
    }
    
    func paymentFormDidDisplay() {
        self.delegate?.paymentFormDidDisplay()
    }
    
    func paymentFormWillHide() {
        self.delegate?.paymentFormWillHide()
    }
    
    func paymentFormDidHide() {
        self.delegate?.paymentFormDidHide()
    }
}
