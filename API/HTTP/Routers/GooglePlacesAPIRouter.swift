//
//  GooglePlacesAPIRouter.swift
//  appName
//
//  Created by Roberto Guzman on 7/13/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation

enum GooglePlacesAPIRouter: APIRouter {
    static let baseURLPath: String = Constants.APIPaths.googlePlaces
    
    case nearbysearch(String, String, String, String)
    case getPlaceDetails(String, String)
    case getPhotoFromReference(String, String)
    
    
    func asURLRequest() throws -> NSMutableURLRequest {
        let result: (path: String, method: HTTPMethod, parameters: [String : AnyObject]) = {
            switch self {
            case .nearbysearch(let location, let radius, let keyword, let types):
                let params = ["location" : location, "radius" : radius, "keyword" : keyword, "type" : types, "opennow" : "true", "rankby" : "prominence"]
                return ("/nearbysearch/json", HTTPMethod.post, params as [String : AnyObject])
            case .getPlaceDetails(let placeid, let fields):
                let params = ["placeid" : placeid, "fields" : fields]
                return ("/details/json", HTTPMethod.post, params as [String : AnyObject])
            case .getPhotoFromReference(let reference, let maxwidth):
                let params = ["photoreference" : reference, "maxwidth" : maxwidth]
                return ("/photo", HTTPMethod.post, params as [String : AnyObject])
            }
            
        }()
        
        
        func escapedParameters(_ parameters: [String: AnyObject]) -> String {
            if parameters.isEmpty {
                return ""
            } else {
                var keyValuePairs = [String]()
                
                for (key, value) in parameters {
                    let stringValue = "\(value)"
                    
                    let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    keyValuePairs.append(key + "=" + "\(escapedValue!)")
                }
                return "?\(keyValuePairs.joined(separator: "&"))"
            }
        }
        
        //combine parameters
        var methodParameters: [String: AnyObject] = [
            Constants.APIKeys.googlePlacesRestAPIKey : Constants.APIValues.googlePlacesRestAPIKey as AnyObject
        ]
        for (key,value) in result.parameters {
            methodParameters[key] = value
        }
        
        //Base URLComponent
        let componentURL = URLComponents(string: "\(GooglePlacesAPIRouter.baseURLPath)\(result.path)\(escapedParameters(methodParameters as [String:AnyObject]))")!
        
        //URL Request
        let requestURL = NSMutableURLRequest(url: componentURL.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: TimeInterval(10 * 1000))
        
        return requestURL
    }
}
