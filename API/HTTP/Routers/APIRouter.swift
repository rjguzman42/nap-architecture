//
//  APIRouter.swift
//  chefspot
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation

protocol APIRouter {
    static var baseURLPath: String { get }
    func asURLRequest() throws -> NSMutableURLRequest
}
