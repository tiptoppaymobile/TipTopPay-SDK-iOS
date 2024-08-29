//
//  StatusPay.swift
//  sdk
//
//  Created by TipTopPay on 12.09.2023.
//  Copyright © 2023 TipTopPay. All rights reserved.
//

import Foundation

enum StatusPay: String {
    case created = "Created"
    case pending = "Pending"
    case authorized = "Authorized"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case declined = "Declined"
}
