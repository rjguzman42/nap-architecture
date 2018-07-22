//
//  FirebaseAnalyticsEngine.swift
//  bitbat
//
//  Created by Roberto Guzman on 5/15/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAnalytics

class FirebaseAnalyticsEngine: AnalyticsEngine {
    
    init() {
    }
    
    func sendAnalyticsEvent(named name: String, metadata: [String : String]) {
        Analytics.logEvent(name, parameters: metadata)
        print("FIRAnalytics --->name: \(name), metadata: \(metadata)")
    }
}
