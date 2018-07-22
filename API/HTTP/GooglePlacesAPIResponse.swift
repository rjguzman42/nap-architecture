//
//  GooglePlacesAPIResponse.swift
//  appName
//
//  Created by Roberto Guzman on 7/13/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation

struct GooglePlacesAPIResponse: Codable {
    let results: [GooglePlace]?
    let result: GooglePlace?
}
