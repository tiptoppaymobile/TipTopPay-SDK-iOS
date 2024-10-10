//
//  GatewayConfiguration.swift
//  TipTopPay
//
//  Created by TipTopPay on 16.06.2023.
//

import Foundation

// MARK: - GatewayConfiguration
struct GatewayConfiguration: Codable {
    let model: GatewayPaymentModel
    let success: Bool
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
        case message = "Message"
    }
}

// MARK: - GatewayPaymentModel
struct GatewayPaymentModel: Codable {
    let logoURL: String?
    let terminalURL: String?
    let widgetURL: String?
    let isCharity, isTest: Bool?
    let terminalName: String?
    let skipExpiryValidation: Bool?
    let agreementPath: String?
    let isCvvRequired: Bool?
    let externalPaymentMethods: [ExternalPaymentMethod]
    let features: Features?
    let supportedCards: [Int]?

    enum CodingKeys: String, CodingKey {
        case logoURL = "LogoUrl"
        case terminalURL = "TerminalUrl"
        case widgetURL = "WidgetUrl"
        case isCharity = "IsCharity"
        case isTest = "IsTest"
        case terminalName = "TerminalName"
        case skipExpiryValidation = "SkipExpiryValidation"
        case agreementPath = "AgreementPath"
        case isCvvRequired = "IsCvvRequired"
        case externalPaymentMethods = "ExternalPaymentMethods"
        case features = "Features"
        case supportedCards = "SupportedCards"
    }
}

// MARK: - ExternalPaymentMethod
struct ExternalPaymentMethod: Codable {
    let type: Int?
    let enabled: Bool
    let appleMerchantID: String?
    let allowedPaymentMethods: [String]?
    let shopID, showCaseID: String?

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case enabled = "Enabled"
        case appleMerchantID = "AppleMerchantId"
        case allowedPaymentMethods = "AllowedPaymentMethods"
        case shopID = "ShopId"
        case showCaseID = "ShowCaseId"
    }
}

// MARK: - Features
struct Features: Codable {
    let isSaveCard: Int
    let isAllowedNotSanctionedCards, isQiwi: Bool

    enum CodingKeys: String, CodingKey {
        case isSaveCard = "IsSaveCard"
        case isAllowedNotSanctionedCards = "IsAllowedNotSanctionedCards"
        case isQiwi = "IsQiwi"
    }
}
