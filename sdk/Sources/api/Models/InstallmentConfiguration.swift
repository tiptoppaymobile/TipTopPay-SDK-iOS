//
//  InstallmentConfiguration.swift
//  sdk
//
//  Created by TipTopPay on 10.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation

struct InstallmentConfiguration: Codable {
    let isCardInstallmentAvailable: Bool?
    let configuration: [Configuration]?

    enum CodingKeys: String, CodingKey {
        case isCardInstallmentAvailable = "IsCardInstallmentAvailable"
        case configuration = "Configuration"
    }
}

struct Configuration: Codable {
    let term: Int?
    let monthlyPayment: Double?

    enum CodingKeys: String, CodingKey {
        case term = "Term"
        case monthlyPayment = "MonthlyPayment"
    }
}

struct InstallmentsData {
    let term: Int
}
