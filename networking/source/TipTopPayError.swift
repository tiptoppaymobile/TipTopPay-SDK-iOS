//
//  TipTopPayError.swift
//  sdk
//
//  Created by TipTopPay on 25.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

public class TipTopPayError: Error {
    public static let defaultCardError = TipTopPayError.init(message: "Unable to determine bank")
    
    public static let parseError = TipTopPayError.init(message: "Не удалось получить ответ")
    
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public class func invalidURL(url: String?) -> TipTopPayError {
        return TipTopPayError.init(message: "Invalid url: \(String(describing: url))")
    }
}
