//
//  NetworkStatus.swift
//  SwiftyPlate
//
//  Created by AKM Ahsanuzzaman on 12/10/20.
//  Copyright © 2020 6sense Technologies. All rights reserved.
//

import Foundation

enum NetworkStatus {
    enum Code: Int {
        case unauthorized   = 401
        case notFound       = 404
        case timeOut        = 408
        case preconditioned = 412
        case invalidParam   = 422
        case serverProblem  = 500
    }
}
