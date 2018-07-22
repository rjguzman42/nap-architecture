//
//  Constants.swift
//  AppName
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation

struct Constants {
    
    
    //MARK: Strings
    
    struct Strings {
        static let appName = "AppName"
    }
    
    
    //MARK: Alerts
    
    struct Alerts {
        static let dismissAlert = NSLocalizedString("Dismiss", comment:"")
        static let generalServerErrorTitle = NSLocalizedString("Oops", comment: "generalServerError title")
        static let generalServerErrorMessage = NSLocalizedString("Looks like something is wrong connecting to the server. Please try again", comment: "generalServerError message")
        static let generalPersistencyErrorTitle = NSLocalizedString("Oops", comment: "generalPersistencyError title")
        static let generalPersistencyErrorMessage = NSLocalizedString("Looks like something is wrong retrieving some information. Please try again", comment: "generalPersistencyError message")
    }
    
    
    //MARK: Cells
    
    struct Cells {
        static let placeCellId = "placeCellId"
    }
    
    
    //MARK: API
    
    struct APIPaths {
        static let appName = ""
        static let googlePlaces = "https://maps.googleapis.com/maps/api/place"
    }
    
    struct APIResponse {
        
    }
    
    struct APIKeys {
        static let appNameRestAPIKey = ""
        static let googlePlacesRestAPIKey = "key"
        static let maxwidth = "maxwidth"
        static let photoreference = "photoreference"
    }
    
    struct APIValues {
        static let appNameRestAPIKey = ""
        static let googlePlacesRestAPIKey = "APIKey Value"
    }
    
    struct APIMessage {
        static let generalError = "general error with server communication"
        static let persistencyError = "general error with local communication"
    }
    
    
    //MARK: Sizes
    
    struct Sizes {
        
        //MARK: Corner Radius
        static let squareCornerRadius: CGFloat = Constants.Sizes.placeCell.width / 20
        
        
        //MARK: Height
        static let singleLineLabelHeight: CGFloat = 25
        static let userInputHeight: CGFloat = 45
        static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        static let navigationBarHeight: CGFloat = 44
        
        
        //MARK: CGSize
        static let customView = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    
}
