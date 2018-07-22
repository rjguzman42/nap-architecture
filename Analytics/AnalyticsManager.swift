//
//  AnalyticsManager.swift
//  bitbat
//
//  Created by Roberto Guzman on 5/15/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation

class AnalyticsManager {
    private let engine: AnalyticsEngine
    
    init(engine: AnalyticsEngine) {
        self.engine = engine
    }
    
    func log(_ event: AnalyticsEvent) {
        engine.sendAnalyticsEvent(named: event.name, metadata: event.metadata)
    }
}
