//
//  APIRouter.swift
//  bitbat
//
//  Created by Roberto Guzman on 3/18/18.
//  Copyright © 2016 fortyTwoSports. All rights reserved.
//

import Foundation
import Alamofire

public enum APIRouter: URLRequestConvertible {
    static let baseURLPath = "http://www.apiPath.com"
    
    case fetchUsers
    
    public func asURLRequest() throws -> URLRequest {
        let result: (path: String, method: Alamofire.HTTPMethod, parameters: [String:AnyObject]) = {
            switch self {
            case .fetchUsers:
                return ("/users/fetchUsers/", .post, [String:AnyObject]())
            }
            
        }()
        
        let authToken: String? = {
            let persistencyManager = PersistencyManager()
            let token = persistencyManager.getAuthToken()
            return token
        }()
    
        let URL = Foundation.URL(string:APIRouter.baseURLPath)!
        var urlRequest = URLRequest(url: URL.appendingPathComponent(result.path))
        urlRequest.httpMethod = result.method.rawValue
        urlRequest.setValue(authToken, forHTTPHeaderField: "auth")

        urlRequest.timeoutInterval = TimeInterval(10 * 1000)
        
        let encoding = try! Alamofire.URLEncoding.default.encode(urlRequest, with: result.parameters)
        
        return encoding
    }
}
