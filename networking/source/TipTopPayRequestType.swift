//
//  TipTopPayRequestType.swift
//  TipTopPay
//
//  Created by TipTopPay on 01.07.2021.
//

import Foundation

public protocol TipTopPayRequestType {
    associatedtype ResponseType: Codable
    var data: TipTopPayRequest { get }
}

public extension TipTopPayRequestType {
    
    func execute(dispatcher: TipTopPayNetworkDispatcher = TipTopPayURLSessionNetworkDispatcher.instance,
                 keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                 onSuccess: @escaping (ResponseType) -> Void,
                 onError: @escaping (Error) -> Void,
                 onRedirect: ((URLRequest) -> Bool)? = nil) {
        dispatcher.dispatch(
            request: self.data,
            onSuccess: { (responseData: Data) in
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
                    let result = try jsonDecoder.decode(ResponseType.self, from: responseData)
                    DispatchQueue.main.async {
                        onSuccess(result)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        if error is DecodingError {
                            onError(TipTopPayError.parseError)
                        } else {
                            onError(error)
                        }
                    }
                }
            },
            onError: { (error: Error) in
                DispatchQueue.main.async {
                    onError(error)
                }
            }, onRedirect: onRedirect
        )
    }
}

