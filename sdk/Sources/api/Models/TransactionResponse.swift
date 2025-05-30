//
//  TransactionResponse.swift
//  sdk
//
//  Created by TipTopPay on 02/06/2021.
//  Copyright © 2021 TipTopPay. All rights reserved.
//

public struct TransactionResponse: Codable {
    public private(set) var success: Bool?
    public private(set) var message: String?
    public private(set) var model: Transaction?
}
