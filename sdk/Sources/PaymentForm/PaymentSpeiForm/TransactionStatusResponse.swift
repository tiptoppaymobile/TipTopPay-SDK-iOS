//
//  TransactionStatusResponse.swift
//  sdk
//
//  Created by TipTopPay on 08.11.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation

public struct TransactionStatusResponse: Codable {
    let success: Bool?
    let model: TransactionModel?
    let message: String?
    let errorCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case model = "Model"
        case message = "Message"
        case errorCode = "ErrorCode"
    }
}
