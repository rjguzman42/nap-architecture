//
//  HTTPMethod.swift
//  appName
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation
import Alamofire

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
    
    func convertToAlamofire() -> Alamofire.HTTPMethod {
        switch self {
        case .post:
            return .post
        case .get:
            return .get
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
}
