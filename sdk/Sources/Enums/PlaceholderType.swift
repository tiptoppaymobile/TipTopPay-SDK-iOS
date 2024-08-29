//
//  PlaceholderType.swift
//  sdk
//
//  Created by TipTopPay on 19.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation

enum PlaceholderType: String {
    case correctCard = "Номер карты"
    case incorrectCard = "Некорректный номер карты"
    case correctExpDate = "ММ / ГГ"
    case incorrectExpDate = "Ошибка в дате"
    case correctCvv = "СVV"
    case incorrectCvv = "Ошибка в CVV"
    
    func toString() -> String {
        return self.rawValue
    }
}
