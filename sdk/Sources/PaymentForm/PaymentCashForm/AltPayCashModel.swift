//
//  AltPayCashModel.swift
//  sdk
//
//  Created by TipTopPay on 10.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation

struct AltPayCash: Codable {
    let transactionID, amount: Int64?
    let isTest: Bool?
    let extensionData: ExtensionData?
    let reason: String?
    let reasonCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case transactionID = "TransactionId"
        case amount = "Amount"
        case isTest = "IsTest"
        case extensionData = "ExtensionData"
        case reason = "Reason"
        case reasonCode = "ReasonCode"
    }
}

struct ExtensionData: Codable {
    let link: String?

    enum CodingKeys: String, CodingKey {
        case link = "Link"
    }
}

