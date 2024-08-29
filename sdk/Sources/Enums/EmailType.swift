//
//  EmailType.swift
//  sdk
//
//  Created by TipTopPay on 14.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation

enum EmailType: String {
    case incorrectEmail = "Некорректный e-mail"
    case receiptEmail = "E-mail для квитанции"
    case defaultEmail = "E-mail"

    func toString() -> String {
        return self.rawValue
    }
}
