//
//  TipTopPayRequest.swift
//
//  Created by TipTopPay on 02.06.2021.
//

public struct TipTopPayRequest {
    public let path: String
    public let method: HTTPMethod
    public let params: [String: Any?]
    public let headers: [String: String]
    
    public init(path: String,
                method: HTTPMethod = .get,
                params: [String: Any?] = [:],
                headers: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.params = params
        self.headers = headers
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum TipTopPayConnectionError: Swift.Error {
    case invalidURL
    case noData
}
