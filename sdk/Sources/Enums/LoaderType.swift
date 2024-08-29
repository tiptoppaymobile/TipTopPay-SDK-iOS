//
//  LoaderType.swift
//  sdk
//
//  Created by TipTopPay on 14.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation

enum LoaderType: String {
    case loaderText = "Загружаем способы оплаты"
    
    func toString() -> String {
        return self.rawValue
    }
}
