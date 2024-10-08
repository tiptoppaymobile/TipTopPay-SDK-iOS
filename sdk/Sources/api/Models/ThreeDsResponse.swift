//
//  ThreeDsResponse.swift
//  sdk
//
//  Created by TipTopPay on 24.09.2020.
//  Copyright © 2020 TipTopPay. All rights reserved.
//

import Foundation

public struct ThreeDsResponse {
    public private(set) var success: Bool
    public private(set) var reasonCode: String?
    
    init(success: Bool, reasonCode: String?) {
        self.success = success
        self.reasonCode = reasonCode
    }
}
