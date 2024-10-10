//
//  Card.swift
//  TipTopPay
//
//  Created by TipTopPay on 08.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import Foundation
import UIKit

public enum CardType: String, CaseIterable {
    case unknown = "Unknown"
    case visa = "Visa"
    case masterCard = "MasterCard"
    case maestro = "Maestro"
    case mir = "MIR"
    case jcb = "JCB"
    case jcb15 = "Jcb15"
    case americanExpress = "AmericanExpress"
    case troy = "Troy"
    case dankort = "Dankort"
    case discover = "Discover"
    case diners = "Diners"
    case instapayments = "Instapayments"
    case humo = "Humo"
    case uatp = "Uatp"
    case unionPay = "UnionPay"
    case uzcard = "Uzcard"
    
    public func toString() -> String {
        switch self {
        case .jcb, .jcb15: return CardType.jcb.rawValue
        default: return self.rawValue
        }
    }
    
    public func getIcon() -> UIImage? {
        let iconName: String?
        switch self {
        case .visa:
            iconName = "ic_visa"
        case .masterCard:
            iconName = "ic_master_card"
        case .maestro:
            iconName = "ic_maestro"
        case .mir:
            iconName = "ic_mir"
        case .jcb:
            iconName = "ic_jcb"
        case .jcb15:
            iconName = "ic_jcb"
        case .americanExpress:
            iconName = "ic_american_express"
        case .troy:
            iconName = "ic_troy"
        case .dankort:
            iconName = "ic_dankort"
        case .discover:
            iconName = "ic_discover"
        case .diners:
            iconName = "ic_diners"
        case .instapayments:
            iconName = "ic_instapayment"
        case .humo:
            iconName = "ic_humo"
        case .uatp:
            iconName = "ic_uatp"
        case .unionPay:
            iconName = "ic_unionPay"
        case .uzcard:
            iconName = "ic_uzcard"
        default:
            iconName = nil
        }
        
        guard iconName != nil else {
            return nil
        }
        
        return UIImage.named(iconName!)
    }
    
    public func regexPattern() -> String {
        switch self {
        case .visa:
            return "^4\\d{0,15}"
        case .masterCard:
            return "^(5[1-5]\\d{0,2}|22[2-9]\\d{0,1}|2[3-7]\\d{0,2})\\d{0,12}"
        case .maestro:
            return "^(?:5[0678]\\d{0,2}|6304|67\\d{0,2})\\d{0,12}"
        case .mir:
            return "^220[0-4]\\d{0,12}"
        case .jcb:
            return "^(?:35\\d{0,2})\\d{0,12}"
        case .jcb15:
            return "^(?:2131|1800)\\d{0,11}"
        case .americanExpress:
            return "^347\\d{0,13}"
        case .dankort:
            return "^(5019|4175|4571)\\d{0,12}"
        case .discover:
            return "^(?:6011|65\\d{0,2}|64[4-9]\\d?)\\d{0,12}"
        case .diners:
            return "^3(?:0([0-5]|9)|[689]\\d?)\\d{0,11}"
        case .instapayments:
            return "^63[7-9]\\d{0,13}"
        case .humo:
            return "(^(9860)\\d{0,12})|(^(55553660)\\d{0,8})"
        case .uatp:
            return "^(?!1800)1\\d{0,14}"
        case .unionPay:
            return "^(62|81)\\d{0,14}"
        case .uzcard:
            return "^(8600)\\d{0,12}"
        default:
            return ""
        }
    }
}

public struct Card {
    private static let publicKeyVersion = "04"
    
    public static func isCardNumberValid(_ cardNumber: String?) -> Bool {
        guard let cardNumber = cardNumber else {
            return false
        }
        
        let number = cardNumber.onlyNumbers()
        guard number.count >= 13 && number.count <= 19 else {
            return false
        }
        
        var checkSum = 0
        
        for element in stride(from: number.count - 1, through: 0, by: -2) {
            checkSum += Int(String(number[number.index(number.startIndex, offsetBy: element)])) ?? 0
        }
        
        for i in stride(from: number.count - 2, through: 0, by: -2) {
            let n = (Int(String(number[number.index(number.startIndex, offsetBy: i)])) ?? 0) * 2
            checkSum += n > 9 ? n - 9 : n
        }
        
        return checkSum % 10 == 0
    }

    public static func isExpDateValid(_ expDate: String?) -> Bool {
        guard let expDate = expDate else {
            return false
        }
        guard expDate.count == 5 else {
            return false
        }
        
        guard let month = Int(expDate.prefix(2)) else {
            return false
        }
        
        return month > 0 && month <= 12

//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/yy"
//
//        guard let date = dateFormatter.date(from: expDate) else {
//            return false
//        }
//
//        var calendar = Calendar.init(identifier: .gregorian)
//        calendar.timeZone = TimeZone.current
//
//        let dayRange = calendar.range(of: .day, in: .month, for: date)
//        var comps = calendar.dateComponents([.year, .month, .day], from: date)
//        comps.day = dayRange?.count ?? 1
//        comps.hour = 24
//        comps.minute = 0
//        comps.second = 0
//
//        guard let aNewDate = calendar.date(from: comps) else {
//            return false
//        }
//
//        let dateNow = dateFormatter.date(from: "02/22")!
//        //let dateNow = Date()
//
//        guard aNewDate.compare(dateNow) == .orderedDescending else {
//            return false
//        }
//
//        return true
    }
    
    public static func isCvvValid(_ cardNumber: String?, _ cvv: String?) -> Bool {
        guard let cvv = cvv else {
            return false
        }
        
        if (cvv.count == 3) || cvv.count == 4 {
            return true
        }
        
        guard let cardNumber = cardNumber else {
            return false
        }

        if (isUzcardCard(cardNumber: cardNumber) || isHumoCard(cardNumber: cardNumber) ) {
            return true
        }
        
        return false
    }
    
    public static func isUzcardCard(cardNumber: String?) -> Bool {
        //Uzcard 8600
        return cardNumber?.prefix(4) == "8600"
    }

    public static func isHumoCard(cardNumber: String?) -> Bool {
        //Humo 9860
        return cardNumber?.prefix(4) == "9860"
    }
    
    public static func cardType(from cardNumber: String) -> CardType {
        let cleanCardNumber = self.cleanCreditCardNo(cardNumber)
        
        guard cleanCardNumber.count > 0 else {
            return .unknown
        }
        
        for cardType in CardType.allCases {
            if let regex = try? NSRegularExpression(pattern: cardType.regexPattern()) {
                let range = NSRange(location: 0, length: cleanCardNumber.utf8.count)
                if regex.firstMatch(in: cleanCardNumber, options: [], range: range) != nil {
                    return cardType
                }
            }
        }
        
        return .unknown
    }
    
    /// Новый метод создания криптограммы
    public static func makeCardCryptogramPacket(_ cardNumber: String, expDate: String, cvv: String, merchantPublicID: String) -> String? {
        guard self.isCardNumberValid(cardNumber) else {
            return nil
        }
        guard self.isExpDateValid(expDate) else {
            return nil
        }
        
        let cardDateComponents = expDate.components(separatedBy: "/")
        let year = cardDateComponents[1]
        let month = cardDateComponents[0]
        let cardDateString = year + month
        
        let cleanCardNumber = self.cleanCreditCardNo(cardNumber)
        let decryptedCryptogram = String.init(format: "%@@%@@%@@%@", cleanCardNumber, cardDateString, cvv, merchantPublicID)
        
        guard let publicKey = dynamicPublicKey(), let cryptogramData = try? RSAUtils.encryptWithRSAPublicKey(str: decryptedCryptogram, pubkeyBase64: publicKey) else {
            return nil
        }
        
        let cryptogramString = RSAUtils.base64Encode(cryptogramData)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        guard let version = PublicKeyData.getValue?.version else { return nil }
        
        let first = String(cleanCardNumber.prefix(6))
        let last = String(cleanCardNumber.suffix(4))
        
        let cardInfo = CardInfo(FirstSixDigits: first, LastFourDigits: last, ExpDateMonth: month, ExpDateYear: year)
        let object = CryptogramType(CardInfo: cardInfo, version: version, value: cryptogramString)
        guard let encode = try? JSONEncoder().encode(object) else { return nil }
        let encodeBase64 = RSAUtils.base64Encode(encode)
        
        return encodeBase64
    }
    
    /// Метод создания криптограммы с внешним ключом
    public static func makeCardCryptogramPacket(cardNumber: String, expDate: String, cvv: String, merchantPublicID: String, publicKey: String, keyVersion: Int) -> String? {
        guard self.isCardNumberValid(cardNumber) else {
            return nil
        }
        guard self.isExpDateValid(expDate) else {
            return nil
        }
        
        let cardDateComponents = expDate.components(separatedBy: "/")
        let year = cardDateComponents[1]
        let month = cardDateComponents[0]
        let cardDateString = year + month
        
        let cleanCardNumber = self.cleanCreditCardNo(cardNumber)
        let decryptedCryptogram = String.init(format: "%@@%@@%@@%@", cleanCardNumber, cardDateString, cvv, merchantPublicID)
        
       guard let cryptogramData = try? RSAUtils.encryptWithRSAPublicKey(str: decryptedCryptogram, pubkeyBase64: publicKey) else {
            return nil
        }
        
        let cryptogramString = RSAUtils.base64Encode(cryptogramData)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        let first = String(cleanCardNumber.prefix(6))
        let last = String(cleanCardNumber.suffix(4))
        
        let convertKeyVersion = String(keyVersion)
        
        let cardInfo = CardInfo(FirstSixDigits: first, LastFourDigits: last, ExpDateMonth: month, ExpDateYear: year)
        let object = CryptogramType(CardInfo: cardInfo, version: convertKeyVersion, value: cryptogramString)
        guard let encode = try? JSONEncoder().encode(object) else { return nil }
        let encodeBase64 = RSAUtils.base64Encode(encode)
        
        return encodeBase64
    }
    
    /// depricated
    private static func makeCardCryptogramPacket(with cardNumber: String, expDate: String, cvv: String, merchantPublicID: String) -> String? {
        guard self.isCardNumberValid(cardNumber) else {
            return nil
        }
        guard self.isExpDateValid(expDate) else {
            return nil
        }
        
        let cardDateComponents = expDate.components(separatedBy: "/")
        let cardDateString = "\(cardDateComponents[1])\(cardDateComponents[0])"
        
        let cleanCardNumber = self.cleanCreditCardNo(cardNumber)
        let decryptedCryptogram = String.init(format: "%@@%@@%@@%@", cleanCardNumber, cardDateString, cvv, merchantPublicID)
        
        guard let publicKey = oldPublicKey(), let cryptogramData = try? RSAUtils.encryptWithRSAPublicKey(str: decryptedCryptogram, pubkeyBase64: publicKey) else {
            return nil
        }
        let cryptogramString = RSAUtils.base64Encode(cryptogramData)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        var packetString = "01"
        let startIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let endIndex = cleanCardNumber.index(cleanCardNumber.endIndex, offsetBy: -4)
        packetString.append(String(cleanCardNumber[cleanCardNumber.startIndex..<startIndex]))
        packetString.append(String(cleanCardNumber[endIndex..<cleanCardNumber.endIndex]))
        packetString.append(cardDateString)
        packetString.append(self.publicKeyVersion)
        packetString.append(cryptogramString)
        
        return packetString
    }
    
    public static func makeCardCryptogramPacket(with cvv: String) -> String? {
        guard let publicKey = oldPublicKey(), let cryptogramData = try? RSAUtils.encryptWithRSAPublicKey(str: cvv, pubkeyBase64: publicKey) else {
            return nil
        }
        let cryptogramString = RSAUtils.base64Encode(cryptogramData)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        var packetString = "03"
        packetString.append(self.publicKeyVersion)
        packetString.append(cryptogramString)
        
        return packetString
    }
    
    public static func cleanCreditCardNo(_ creditCardNo: String) -> String {
        return creditCardNo.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
    
    private static func dynamicPublicKey() -> String? {
        return PublicKeyData.getValue?.Pem
    }
    
    private static func oldPublicKey() -> String? {
        guard let filePath = Bundle.mainSdk.path(forResource: "PublicKey", ofType: "txt") else {
            return nil
        }
        let key = try? String(contentsOfFile: filePath).replacingOccurrences(of: "\n", with: "")
        return key
    }
}
