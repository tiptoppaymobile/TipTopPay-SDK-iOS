//
//  PaymentSpeiDetails.swift
//  sdk
//
//  Created by TipTopPay on 27.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation

struct PaymentSpeiDetails {
    let transactionId: Int64
    let amount: String
    let clabe: String
    let bank: String
    let paymentConcept: String
    let paymentDeadline: String
    var email: String?
}
