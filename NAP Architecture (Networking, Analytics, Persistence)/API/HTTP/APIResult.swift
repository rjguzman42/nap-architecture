//
// APIResult.swift
//  bitbat
//
//  Created by Roberto Guzman on 3/18/18.
//  Copyright © 2016 fortyTwoSports. All rights reserved.
//

import Foundation
import Argo

public enum APIResult<T> {
    case success(T)
    case error(NSError)
    case notFound
    case serverError(Int, String?)
    case clientError(Int, String?)
    case unexpectedResponse(JSON)
}
