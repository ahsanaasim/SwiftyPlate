//
//  Endpoint.swift
//  SwiftyPlate
//
//  Created by AKM Ahsanuzzaman on 12/10/20.
//  Copyright © 2020 6sense Technologies. All rights reserved.
//

import Foundation
import Alamofire

protocol Endpoint {
    var method: HTTPMethod { get }
    var path: String { get }
    var params: [String: Any] { get }
    var encoding: ParameterEncoding { get set}
}

extension Endpoint {
    var encoding: ParameterEncoding { get{return URLEncoding.default} set {} }
}
