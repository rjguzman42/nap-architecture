//
//  Theme.swift
//  chefspot
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    //MARK: Colors
    
    enum Colors {
        case background
        case primaryText
        case primaryTextLight
        case navBar
        case toolBar
        
        var color: UIColor {
            switch self {
            case .background: return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            case .primaryText: return UIColor(red: 033/255, green: 033/255, blue: 033/255, alpha: 1.0)
            case .primaryTextLight: return UIColor(red: 084/255, green: 085/255, blue: 084/255, alpha: 1.0)
            case .navBar: return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            case .toolBar: return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            }
        }
    }
    
    
    //MARK: Fonts
    
    enum Fonts {
        case primary
        case primarySmall
        case primaryMedium
        case primaryLarge
        case primaryDemiBold
        case primaryLargeBold
        case primarySuperLargeBold
        case titleBold
        
        var font: UIFont {
            switch self {
            case .primary: return UIFont(name: "AvenirNext-Regular", size: 16)!
            case .primarySmall: return UIFont(name: "AvenirNext-Regular", size: 12)!
            case .primaryMedium: return UIFont(name: "AvenirNext-Medium", size: 16)!
            case .primaryLarge: return UIFont(name: "AvenirNext-Regular", size: 20)!
            case .primaryDemiBold: return UIFont(name: "AvenirNext-DemiBold", size: 16)!
            case .primaryLargeBold: return UIFont(name: "AvenirNext-Bold", size: 20)!
            case .primarySuperLargeBold: return UIFont(name: "AvenirNext-Bold", size: 30)!
            case .titleBold: return UIFont(name: "AvenirNext-Medium", size: 18)!
            }
        }
    }
}
