//
//  ChargeRequest.swift
//  TipTopPay
//
//  Created by TipTopPay on 01.07.2021.
//

import TipTopPayNetworking

final class ChargeRequest: BaseRequest, TipTopPayRequestType {
    typealias ResponseType = TransactionResponse
    var data: TipTopPayRequest {
        return TipTopPayRequest(path: TipTopPayHTTPResource.charge.asUrl(apiUrl: apiUrl), method: .post, params: params, headers: headers)
    }
}

final class InstallmentsRequest: BaseRequest, TipTopPayRequestType {
    typealias ResponseType = InstallmentConfigurationResponse
    var data: TipTopPayRequest {
        let path = TipTopPayHTTPResource.installmentsCalculateSumByPeriod.asUrl(apiUrl: apiUrl)
       
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

