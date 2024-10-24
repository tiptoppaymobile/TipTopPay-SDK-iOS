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
