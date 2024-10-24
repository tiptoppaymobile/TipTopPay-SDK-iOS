//
//  AltPayCashRequest.swift
//  sdk
//
//  Created by TipTopPay on 10.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import TipTopPayNetworking

final class AltPayCashRequest: BaseRequest, TipTopPayRequestType {
    typealias ResponseType = AltPayCashResponse
    var data: TipTopPayRequest {
        let path = TipTopPayHTTPResource.altPayCash.asUrl(apiUrl: apiUrl)
       
        guard var component = URLComponents(string: path) else { return TipTopPayRequest(path: path, method: .post, params: params, headers: headers) }
       
        if !queryItems.isEmpty {
            let items = queryItems.compactMap { return URLQueryItem(name: $0, value: $1) }
            component.queryItems = items
        }
        
        guard let url = component.url else { return TipTopPayRequest(path: path, method: .post, params: params, headers: headers) }
        let fullPath = url.absoluteString
        
        return TipTopPayRequest(path: fullPath, method: .post, params: params, headers: headers)
    }
}
