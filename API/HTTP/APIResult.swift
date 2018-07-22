//
//  APIResult.swift
//  appName
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation

public enum APIResult<T> {
    case success(T)
    case error(NSError)
    case notFound
    case serverError(Int, String?)
    case clientError(Int, String?)
    case persistencyError(String?)
    case unexpectedResponse
}
