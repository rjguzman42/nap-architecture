//
//  AnalyticsEngine.swift
//  bitbat
//
//  Created by Roberto Guzman on 5/15/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation

protocol AnalyticsEngine: class {
    func sendAnalyticsEvent(named name: String, metadata: [String : String])
}
