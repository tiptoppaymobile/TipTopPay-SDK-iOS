//
//  WaitStatusRequest.swift
//  sdk
//
//  Created by TipTopPay on 08.11.2024.
//  Copyright © 2024 TipTopPay. All rights reserved.
//

import Foundation
import TipTopPayNetworking

final class WaitStatusRequest: BaseRequest, TipTopPayRequestType {
    typealias ResponseType = TransactionStatusResponse
    
    var data: TipTopPayRequest {
        let path = TipTopPayHTTPResource.waitStatus.asUrl(apiUrl: apiUrl)
        
        return TipTopPayRequest(
            path: path,
            method: .post,
            params: params,
            headers: headers
        )
    }
}
