//
//  BankInfoRequest.swift
//  TipTopPay
//
//  Created by TipTopPay on 01.07.2021.
//

import TipTopPayNetworking

class BankInfoRequest: BaseRequest, TipTopPayRequestType {
    private let firstSix: String
    init(firstSix: String) {
        self.firstSix = firstSix
    }
    typealias ResponseType = BankInfoResponse
    var data: TipTopPayRequest {
        return TipTopPayRequest(path: "https://api.tiptoppay.kz/bins/info/\(firstSix)", method: .get)
    }
}
