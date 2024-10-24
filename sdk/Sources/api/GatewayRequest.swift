//
//  GatewayRequest.swift
//  TipTopPay
//
//  Created by TipTopPay on 16.06.2023.
//

import TipTopPayNetworking

struct PayButtonStatus {
    var isSaveCard: Int?
    var isOnInstallments: Bool
    var isOnCash: Bool
    var isCvvRequired: Bool?
    var cashMethods: [Int]? = []
    var minAmount: Int?
    
    init(isSaveCard: Int? = nil,
         isOnInstallments: Bool = false,
         isOnCash: Bool = false,
         isCvvRequired: Bool? = nil,
         cashMethods: [Int]? = [],
         minAmount: Int? = nil) {
        self.isSaveCard = isSaveCard
        self.isOnInstallments = isOnInstallments
        self.isCvvRequired = isCvvRequired
        self.isOnCash = isOnCash
        self.cashMethods = cashMethods
        self.minAmount = minAmount
    }
}

final class GatewayRequest {
    static var payButtonStatus: PayButtonStatus?
    
    private class PayRequestData<Model: Codable>: BaseRequest, TipTopPayRequestType {
        
        var data: TipTopPayNetworking.TipTopPayRequest
        typealias ResponseType = Model
        
        fileprivate init(baseURL: String, terminalPublicId: String?) {
            let baseURL = baseURL + "merchant/configuration/"
            guard var path = URLComponents(string: baseURL) else {
                data = .init(path: "")
                return
            }
            
            let queryItems: [URLQueryItem] = [
                .init(name: "terminalPublicId", value: terminalPublicId),
            ]
            path.queryItems = queryItems
            
            let string = path.url?.absoluteString ?? ""
            data = .init(path: string)
        }
    }
}

extension GatewayRequest {

    public static func getTerminalConfiguration(baseURL: String, terminalPublicId: String?, completion: @escaping (PayButtonStatus?, Error?) -> Void) {
        var result = PayButtonStatus()

        PayRequestData<GatewayConfiguration>(baseURL: baseURL, terminalPublicId: terminalPublicId).execute { value in
            result.isSaveCard = value.model.features?.isSaveCard
            result.isCvvRequired = value.model.isCvvRequired
            result.cashMethods = value.model.externalPaymentMethods.flatMap { $0.cashMethods ?? [] }
            if let minAmountValue = value.model.externalPaymentMethods.compactMap({ $0.minAmount }).first {
                result.minAmount = minAmountValue
            }

            for element in value.model.externalPaymentMethods {
                guard let rawValue = element.type, let value = CaseOfBank(rawValue: rawValue) else { continue }

                switch value {
                case .installments:
                    result.isOnInstallments = element.enabled
                case .cash:
                    result.isOnCash = element.enabled
                }
            }

            self.payButtonStatus = result
            completion(result, nil)

        } onError: { error in
            let code = error._code < 0 ? -error._code : error._code
            self.payButtonStatus = code == 1009 ? nil : result
            completion(nil, error)
        }
    }
}

enum CaseOfBank: Int {
    case installments = 16
    case cash = 14
}
