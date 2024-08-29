//
//  Strings+Extensions.swift
//  sdk
//
//  Created by TipTopPay on 16.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import Foundation

extension String {
    static let bundleName = "TipTopPaySdkResources"
    static let errorWord = "Ошибка"
    static let noData = "Отсутствует соединение с сервером"
    static let errorCreatingCryptoPacket = "Ошибка при создании крипто-пакета"
    static let informationWord = "Информация"
    static let noConnection = "Проверьте подключение к интернету"
    static let infoOutdated = "Данные могли устареть"
    static let noBankApps = "Приложение банка не найдено"
    
    static let RUBLE_SIGN = "\u{20BD}"
    static let EURO_SIGN = "\u{20AC}"
    static let GBP_SIGN = "\u{00A3}"
}

extension String {

    func formattedCardNumber() -> String {
        let mask = "XXXX XXXX XXXX XXXX XXX"
        return self.onlyNumbers().formattedString(mask: mask, ignoredSymbols: nil)
    }
    
    func clearCardNumber() -> String {
        return self.onlyNumbers()
    }
    
    func formattedCardExp() -> String {
        let mask = "XX/XX"
        return self.onlyNumbers().formattedString(mask: mask, ignoredSymbols: nil)
    }
    
    func cleanCardExp() -> String {
        return self.onlyNumbers()
    }
    
    func formattedCardCVV() -> String {
        let mask = "XXXX"
        return self.onlyNumbers().formattedString(mask: mask, ignoredSymbols: nil)
    }

    func emailIsValid() -> Bool {
        let emailRegex = "^(?:[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9]{2,}(?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$";
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with:self)
    }
    
    func formattedString(mask: String, ignoredSymbols: String?) -> String {
        let cleanString = self.onlyNumbers()
        
        var result = ""
        var index = cleanString.startIndex
        for ch in mask {
            if index == cleanString.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanString[index])
                index = cleanString.index(after: index)
            } else {
                result.append(ch)
                
                if ignoredSymbols?.contains(ch) == true {
                    index = cleanString.index(after: index)
                }
            }
        }
        return result
    }
    
    func onlyNumbers() -> String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    func toInt() -> Int? {
        return Int(self)
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
