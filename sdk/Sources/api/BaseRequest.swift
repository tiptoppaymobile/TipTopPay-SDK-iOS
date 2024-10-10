//
//  BaseRequest.swift
//  TipTopPay
//
//  Created by TipTopPay on 01.07.2021.
//

import Foundation

open class BaseRequest {
    var queryItems: [String: String?]
    var params: [String: Any?]
    var headers: [String: String]
    var apiUrl: String
    
    public init(queryItems: [String: String?] = [:],
                params: [String: Any?] = [:],
                headers: [String: String] = [:],
                apiUrl: String = "") {
        self.params = params
        self.headers = headers
        self.apiUrl = apiUrl
        self.queryItems = queryItems
    }
}
