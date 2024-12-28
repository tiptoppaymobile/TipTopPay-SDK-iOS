//
//  StatusPay.swift
//  sdk
//
//  Created by TipTopPay on 12.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation

enum StatusPay: String {
    case created = "Created"
    case pending = "Pending"
    case authorized = "Authorized"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case declined = "Declined"
}

public struct Receipt: Codable {
    public struct Item: Codable {
        public let label: String
        public let price: Double
        public let quantity: Double
        public let amount: Double
        public let vat: Int
        public let method: Int
        public let object: Int
        
        public init(label: String, price: Double, quantity: Double, amount: Double, vat: Int, method: Int, object: Int) {
            self.label = label
            self.price = price
            self.quantity = quantity
            self.amount = amount
            self.vat = vat
            self.method = method
            self.object = object
        }
    }

    public let items: [Item]
    public let taxationSystem: Int
    public let email: String
    public let phone: String
    public let isBso: Bool
    public let amounts: Amounts?

    public struct Amounts: Codable {
        public let electronic: Double
        public let advancePayment: Double
        public let credit: Double
        public let provision: Double
        
        public init(electronic: Double, advancePayment: Double, credit: Double, provision: Double) {
            self.electronic = electronic
            self.advancePayment = advancePayment
            self.credit = credit
            self.provision = provision
        }
    }

    public init(items: [Item], taxationSystem: Int, email: String, phone: String, isBso: Bool, amounts: Amounts) {
        self.items = items
        self.taxationSystem = taxationSystem
        self.email = email
        self.phone = phone
        self.isBso = isBso
        self.amounts = amounts
    }
}
