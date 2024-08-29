//
//  PostThreeDsRequest.swift
//  TipTopPay
//
//  Created by TipTopPay on 01.07.2021.
//

import TipTopPayNetworking

class PostThreeDsRequest: BaseRequest, TipTopPayRequestType {
    typealias ResponseType = TransactionResponse
    var data: TipTopPayRequest {
        return TipTopPayRequest(path: TipTopPayHTTPResource.post3ds.asUrl(apiUrl: apiUrl), method: .post, params: params, headers: headers)
    }
}
