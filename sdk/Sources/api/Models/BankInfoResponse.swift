//
//  BankInfoResponse.swift
//  sdk
//
//  Created by TipTopPay on 29.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

struct BankInfoResponse: Codable {
    let success: Bool?
    let message: String?
    let model: BankInfo?
    
    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
        case message = "Message"
    }
}
