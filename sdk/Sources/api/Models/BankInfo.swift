//
//  BankInfo.swift
//  sdk
//
//  Created by TipTopPayon 09.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

public struct BankInfo: Codable {
    let logoURL: String?
    let convertedAmount: String?
    let currency: String?
    let hideCvvInput: Bool?
    let cardType: NameCardType.RawValue?
    let isCardAllowed: Bool?
    
    enum CodingKeys: String, CodingKey {
        case logoURL = "LogoUrl"
        case convertedAmount = "ConvertedAmount"
        case currency = "Currency"
        case hideCvvInput = "HideCvvInput"
        case cardType = "CardType"
        case isCardAllowed = "IsCardAllowed"
    }
}

enum NameCardType: String, Codable {
    case unknown = "Unknown"
    case visa = "Visa"
    case masterCard = "MasterCard"
    case maestro = "Maestro"
    case mir = "MIR"
    case jcb = "Jcb"
    case jcb15 = "Jcb15"
    case americanExpress = "AmericanExpress"
    case troy = "Troy"
    case dankort = "Dankort"
    case discover = "Discover"
    case diners = "Diners"
    case instapayments = "Instapayments"
    case humo = "Humo"
    case uatp = "Uatp"
    case unionPay = "UnionPay"
    case uzcard = "Uzcard"
    
    var string: String {
        switch self {
        case .jcb, .jcb15: return NameCardType.jcb.rawValue
        default: return rawValue
        }
    }
}

public struct InstallmentConfigurationResponse: Codable {
    let model: InstallmentConfiguration?
    let success: Bool?

    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
    }
}

// MARK: - Model
struct InstallmentConfiguration: Codable {
    let isCardInstallmentAvailable: Bool?
    let configuration: [Configuration]?

    enum CodingKeys: String, CodingKey {
        case isCardInstallmentAvailable = "IsCardInstallmentAvailable"
        case configuration = "Configuration"
    }
}

// MARK: - Configuration
struct Configuration: Codable {
    let term: Int?
    let monthlyPayment: Double?

    enum CodingKeys: String, CodingKey {
        case term = "Term"
        case monthlyPayment = "MonthlyPayment"
    }
}
