//
//  GatewayRequest.swift
//  TipTopPay
//
//  Created by TipTopPay on 16.06.2023.
//

import TipTopPayNetworking

struct PayButtonStatus {
    var isSaveCard: Int?
    
    init(isSaveCard: Int? = nil) {
        self.isSaveCard = isSaveCard
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
    
    public static func getTerminalConfiguration(baseURL: String, terminalPublicId: String?, completion: @escaping (PayButtonStatus?) -> Void) {
        var result = PayButtonStatus()
        
        PayRequestData<GatewayConfiguration>(baseURL: baseURL, terminalPublicId: terminalPublicId).execute { value in
            result.isSaveCard = value.model.features?.isSaveCard
            
            self.payButtonStatus = result
            
            return completion(result)
            
        } onError: { error in
            print(error.localizedDescription)
            let code = error._code < 0 ? -error._code : error._code
            self.payButtonStatus = code == 1009 ? nil : result
            if code == 1009 {
                return completion(nil)
            }
            
            return completion(result)
        }
    }
}
