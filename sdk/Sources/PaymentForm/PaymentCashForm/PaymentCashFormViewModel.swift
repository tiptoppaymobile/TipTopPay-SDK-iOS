//
//  PaymentCashFormViewModel.swift
//  sdk
//
//  Created by TipTopPay on 09.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation
import TipTopPayNetworking

final class PaymentCashFormViewModel {
    
    // MARK: - Properties
    
    private (set) var configuration: TipTopPayConfiguration
    
    struct CashMethod {
        let id: Int
        let serverKey: String
        let buttonTextKey: String
        let altPayType: String
    }
    
    // MARK: - Input
    
    var name: String = "" {
        didSet {
            isNameValid = !name.isEmpty
            updateFieldsValidState()
        }
    }
    
    var email: String = "" {
        didSet {
            isEmailValid = email.emailIsValid()
            updateFieldsValidState()
        }
    }
    
    var availableMethods: [Int] = [] {
        didSet {
            onAvailableMethodsChange?(availableMethods)
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            isLoadingStateChange?(isLoading)
        }
    }
    
    let cashMethods: [CashMethod] = [
        CashMethod(id: 0, serverKey: "OXXO", buttonTextKey: "ttpsdk_cash_method_oxxo".localized, altPayType: "CashOxxo"),
        CashMethod(id: 1, serverKey: "Convenience Store", buttonTextKey: "ttpsdk_cash_method_convenience_store".localized, altPayType: "CashCStores"),
        CashMethod(id: 2, serverKey: "Pharmacy", buttonTextKey: "ttpsdk_cash_method_pharmacy".localized, altPayType: "CashFarmacias")
    ]
    
    // MARK: - Output
    
    var isNameValid: Bool = false {
        didSet { onNameValidationChange?(isNameValid) }
    }
    
    var isEmailValid: Bool = false {
        didSet { onEmailValidationChange?(isEmailValid) }
    }
    
    var areFieldsValid: Bool = false {
        didSet { onFieldsValidationChange?(areFieldsValid) }
    }
    
    // MARK: - Handlers
    
    var onNameValidationChange: ((Bool) -> Void)?
    var onEmailValidationChange: ((Bool) -> Void)?
    var onFieldsValidationChange: ((Bool) -> Void)?
    var onAvailableMethodsChange: (([Int]) -> Void)?
    var onCashMethodsChange: (([CashMethod]) -> Void)?
    var onPaymentSuccess: ((AltPayCashResponse?) -> Void)?
    var onPaymentError: ((TipTopPayError) -> Void)?
    var onDismiss: (() -> Void)?
    var isLoadingStateChange: ((Bool) -> Void)?
    
    // MARK: - Init
    
    init(configuration: TipTopPayConfiguration) {
        self.configuration = configuration
    }
    
    func updateConfigurationWithNewData() {
        configuration.paymentData.payer?.firstName = name
        configuration.paymentData.email = email
    }
    
    func updateFieldsValidState() {
        isNameValid = !name.isEmpty
        isEmailValid = email.emailIsValid()
        areFieldsValid = isNameValid && isEmailValid
        onFieldsValidationChange?(areFieldsValid)
    }
    
    func fetchCashMethods() {
        guard let availableMethods = configuration.paymentData.cashMethods else {
            return
        }
        
        self.availableMethods = availableMethods
        onAvailableMethodsChange?(availableMethods)
        onCashMethodsChange?(self.cashMethods)
    }
    
    func payWithCash(altPayType: String) {
        
        isLoading = true
        
        TipTopPayApi.altPayCash(with: configuration, altPayType: altPayType) { [weak self] result in
            switch result {
            case .success(let response):
                if let onPaymentSuccess = self?.onPaymentSuccess {
                    onPaymentSuccess(response)
                }
            case .failure(let error):
                self?.onPaymentError?(error)
            }
        }
    }
    
    func triggerDismiss() {
        onDismiss?()
    }
}
