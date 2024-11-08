//
//  TransactionModel.swift
//  sdk
//
//  Created by TipTopPay on 08.11.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation

public struct TransactionModel: Codable {
    let transactionId: Int64?
    let providerQrId: String?
    let escrowAccumulationId: String?
    let status: String?
    let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "TransactionId"
        case providerQrId = "ProviderQrId"
        case escrowAccumulationId = "EscrowAccumulationId"
        case status = "Status"
        case statusCode = "StatusCode"
    }
}
