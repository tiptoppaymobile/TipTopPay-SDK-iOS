//
//  BinInfoRequest.swift
//  sdk
//
//  Created by TipTopPay on 10.10.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import TipTopPayNetworking
import Foundation

final class BinInfoRequest: BaseRequest, TipTopPayRequestType {
    typealias ResponseType = BankInfoResponse
    var data: TipTopPayRequest {
        let path = TipTopPayHTTPResource.binInfo.asUrl(apiUrl: apiUrl)
       
        guard var component = URLComponents(string: path) else { return TipTopPayRequest(path: path, headers: headers) }
       
        if !queryItems.isEmpty {
            let items = queryItems.compactMap { return URLQueryItem(name: $0, value: $1) }
            component.queryItems = items
        }
        
        guard let url = component.url else { return TipTopPayRequest(path: path, headers: headers) }
        let fullPath = url.absoluteString
        
        return TipTopPayRequest(path: fullPath, headers: headers)
    }
}
