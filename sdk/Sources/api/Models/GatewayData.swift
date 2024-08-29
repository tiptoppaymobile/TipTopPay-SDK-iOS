//
//  PayData.swift
//  TipTopPay
//
//  Created by TipTopPay on 19.06.2023.
//

import Foundation

enum Scheme: String, Codable {
    case charge = "0"
    case auth = "1"
}

struct PayData: Codable {
    let publicId: String?
    let amount: String?
    let accountId: String?
    let invoiceId: String?
    let browser: String?
    let description: String?
    let currency: String?
    let email, ipAddress, os: String?
    let scheme: Scheme.RawValue
    let ttlMinutes: Int?
    let successRedirectURL: String?
    let failRedirectURL: String?
    let saveCard: Bool?
    let jsonData: String?

    enum CodingKeys: String, CodingKey {
        case publicId = "PublicId"
        case amount = "Amount"
        case accountId = "AccountId"
        case invoiceId = "InvoiceId"
        case browser = "Browser"
        case currency = "Currency"
        case description = "Description"
        case email = "Email"
        case ipAddress = "IpAddress"
        case os = "Os"
        case scheme = "Scheme"
        case ttlMinutes = "TtlMinutes"
        case successRedirectURL = "SuccessRedirectUrl"
        case failRedirectURL = "FailRedirectUrl"
        case saveCard = "SaveCard"
        case jsonData = "JsonData"
    }
}

// MARK: - ResponseTransactionModel
struct ResponseTransactionModel: Codable {
    let success: Bool?
    let message: String?
    let model: ResponseStatusModel?
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case message = "Message"
        case model = "Model"
    }
}

// MARK: - ResponseStatusModel
struct ResponseStatusModel: Codable {
    let transactionId: Int64?
    let status: StatusPay.RawValue?
    let statusCode: Int?
    let providerQrId: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "TransactionId"
        case status = "Status"
        case statusCode = "StatusCode"
        case providerQrId = "ProviderQrId"
    }
}

