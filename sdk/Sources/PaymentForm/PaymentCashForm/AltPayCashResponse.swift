//
//  AltPayCashResponse.swift
//  sdk
//
//  Created by TipTopPay on 10.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation

public struct AltPayCashResponse: Codable {
    let model: AltPayCash?
    let success: Bool?
    let message, errorCode: String?

    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
        case message = "Message"
        case errorCode = "ErrorCode"
    }
}

public struct StpSpeiPaymentDetailsResponse: Codable {
    let success: Bool?
    let message, errorCode: String?

    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case message = "Message"
        case errorCode = "ErrorCode"
    }
}

