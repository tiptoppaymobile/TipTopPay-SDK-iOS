//
//  PublicKeyRequest.swift
//  TipTopPay
//
//  Created by TipTopPay on 31.05.2023.
//

import Foundation
import TipTopPayNetworking

class Network: BaseRequest, TipTopPayRequestType {
    var data: TipTopPayNetworking.TipTopPayRequest
    typealias ResponseType = PublicKeyData
    
    private init() {data = .init(path: PublicKeyData.apiURL + "payments/publickey")}
    
    public static func updatePublicCryptoKey() {
        Network().execute { value in
            value.save()
        } onError: { string in
            print(string.localizedDescription)
        }
    }
}

