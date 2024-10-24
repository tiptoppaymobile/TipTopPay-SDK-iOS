//
//  InstallmentConfigurationResponse.swift
//  sdk
//
//  Created by TipTopPay on 10.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation

public struct InstallmentConfigurationResponse: Codable {
    let model: InstallmentConfiguration?
    let success: Bool?

    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
    }
}
