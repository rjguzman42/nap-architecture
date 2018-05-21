//
//  PersistRouter.swift
//  bitbat
//
//  Created by Roberto Guzman on 5/12/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation

struct PersistRouter {
    
    //MARK: App
    static let launchCount = "launchCount"
    static let firstLaunch = "firstLaunch"
    
    //MARK: SSKeychain
    static let keychainAppService = "authClient"
    
    //MARK: User
    static let authToken = "authToken"
    static let user = "user"

}
