//
//  HTTPManager.swift
//  bitbat
//
//  Created by Roberto Guzman on 3/18/18.
//  Copyright © 2016 fortyTwoSports. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import Runes


typealias JsonTaskCompletionHandler = (JSON?,HTTPURLResponse?, NSError?, String?) -> Void

open class HTTPManager {
    var loggingEnabled = false
    var currentRequests: [Request] = []
    
    // MARK: Server Communication
    
    func sendResource<T : Argo.Decodable>(_ request: URLRequestConvertible, imageData: Data?, videoData: Data?, params: NSDictionary?, rootKey: String?, completion: @escaping (APIResult<T>) -> Void) where T.DecodedType == T {
        // Make request -> Any -> [JSON -> T]
        multipartFetch(request, imageData: imageData, videoData: videoData, params: params, parseBlock: { (json) -> T? in
            
            let j: JSON
            if let root = rootKey {
                let rootJSON: Decoded<JSON> = (json <| root) <|> pure(json)
                j = rootJSON.value ?? .null
            } else {
                j = json
            }
            
            return T.decode(j).value
            }, completion: completion)
    }
    
    func fetchResource<T : Argo.Decodable>(_ request: URLRequestConvertible, rootKey: String?, completion: @escaping (APIResult<T>) -> Void) where T.DecodedType == T {
        // Make request -> AnyObject -> [JSON -> T]
        fetch(request, parseBlock: { (json) -> T? in
            
            let j: JSON
            if let root = rootKey {
                let rootJSON: Decoded<JSON> = (json <| root) <|> pure(json)
                j = rootJSON.value ?? .null
            } else {
                j = json
            }
            
            return T.decode(j).value
            }, completion: completion)
    }
    func fetchGenericResource<T : Argo.Decodable>(_ request: URLRequestConvertible, rootKey: String?, completion: @escaping (APIResult<T>) -> Void) where T.DecodedType == T {
        // Make request -> AnyObject -> [JSON -> T]
        fetch(request, parseBlock: { (json) -> T? in
            
            let j: JSON
            if let root = rootKey {
                let rootJSON: Decoded<JSON> = (json <| root) <|> pure(json)
                j = rootJSON.value ?? .null
            } else {
                j = json
            }
            
            /*
             * Swift 2 version
            let j: JSON
            if let root = rootKey {
                let rootJSON: Decoded<JSON> = (json <| root) <|> pure(json)
                j = rootJSON.value ?? .Null
            } else {
                j = json
            }
            */
            
            switch j {
            case .object( _):
                return nil
            default:
                BBDebugLog.DLog("Response was not an array can not continue")
                return nil
                
            }
            }, completion: completion)
    }
    
    func fetchUser<T : Argo.Decodable>(_ request: URLRequestConvertible, rootKey: String?, completion: @escaping (APIResult<T>) -> Void) where T.DecodedType == T {
        // Make request -> AnyObject -> [JSON -> T]
        fetch(request, parseBlock: { (json) -> T? in
            
            let j: JSON
            if let root = rootKey {
                let rootJSON: Decoded<JSON> = (json <| root) <|> pure(json)
                j = rootJSON.value ?? .null

            } else {
                j = json
            }
            
          
            return T.decode(j).value
            }, completion: completion)
    }

    func fetchCollection<T: Argo.Decodable>(_ request: URLRequestConvertible, rootKey: String?, completion: @escaping (APIResult<[T]>) -> Void) -> Request where T.DecodedType == T {
        return fetch(request, parseBlock: { (json) in
            
            let j: JSON
            if let root = rootKey {
                let rootJSON: Decoded<JSON> = (json <| root) <|> pure(json)
                j = rootJSON.value ?? .null
            } else {
                j = json
            }
            
            switch j {
            case .array(let array):
                return array.map { T.decode($0).value!}// use flatmap on array to not add nil objects and prevent crashes
            default:
                BBDebugLog.DLog("Response was not an array can not continue")
                return nil
                
            }
            }, completion: completion)

    }
    func fetchGenericCollection<T: Argo.Decodable>(_ request: URLRequestConvertible, rootKey: String?, completion: @escaping (APIResult<[T]>) -> Void) where T.DecodedType == T {
        fetch(request, parseBlock: { (json) in
            
            let j: JSON
            if let root = rootKey {
                let rootJSON: Decoded<JSON> = (json <| root) <|> pure(json)
                j = rootJSON.value ?? .null
            } else {
                j = json
            }
            
            switch j {
            case .array(let array):
                return  array.flatMap { Array.decode($0).value! }
            default:
                BBDebugLog.DLog("Response was not an array can not continue")
                return nil
                
            }
            }, completion: completion)
        
    }
        
    func fetch<T>(_ request: URLRequestConvertible, parseBlock: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) -> Request{
        //Make request
        return jsonTaskWithRequest(request) { [weak self]  (json, response, error, errorDescription) in
            if let weakSelf = self {
                DispatchQueue.main.async() {
                    if let e = error {
                        if let res = response {
                            switch res.statusCode {
                            case 200: break
                            case 404: completion(.notFound)
                            case 400...499: completion(.clientError(res.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                            case 500...599: completion(.serverError(res.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                            default:
                                completion(.error(e))
                                BBDebugLog.DLog("received HTTP \(res.statusCode) which was not handled")
                            }
                            
                        } else {
                            completion(.error(e))
                        }
                    } else {
                        switch response!.statusCode {
                        case 200:
                            if let resource = parseBlock(json!) {
                                completion(.success(resource))
                            } else {
                                BBDebugLog.DLog("WARNING could not parse the following JSON as a \(T.self)")
                                BBDebugLog.DLog(json!)
                                completion(.unexpectedResponse(json!))
                            }
                        case 404: completion(.notFound)
                        case 400...499: completion(.clientError(response!.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                        case 500...599: completion(.serverError(response!.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                        default:
                            BBDebugLog.DLog("received HTTP \(response!.statusCode) which was not handled")
                        }
                        
                    }
                }
            }
            
        }
    }
    func processRegistrationResponse(_ resultString: String?) -> String{
        guard let result = resultString else {return ""}
        
        //invalid token
        let invalidToken:String = "\"Invalid auth token.\""
        let isInvalidToken =  result == invalidToken
        if(isInvalidToken) {
            BBDebugLog.DLog("Invalid auth token.")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logOut()
            return BBConstants.Strings.invalidToken
            
        }
        if(result == "\"Email address already exists\"") {
            return BBConstants.Strings.emailExists
        }
        if(result == "\"Email and password do not match\"") {
            return BBConstants.Strings.emailPasswordNotMatch
        }
        if(result == "\"Email does not exist\"") {
            return BBConstants.Strings.emailDoesntExist
        }
        return BBConstants.Strings.serverCommunicationError
    }
    func jsonTaskWithRequest(_ request: URLRequestConvertible, completion: @escaping JsonTaskCompletionHandler) -> Request {
        var requestTask: Request?
        requestTask = Alamofire.request(request)
            .validate()
//            .validate(statusCode: 200..<300)
//            .validate(contentType: ["application/json"])
            .responseJSON { response in
                let defaultValue = "defaultREquestValue"
//                self.currentRequests.removeObject(requestTask!)!
                guard response.result.isSuccess else {
                    self.debugLog("Received an error from HTTP \(request.urlRequest!.httpMethod ?? defaultValue) to \(request.urlRequest!.url!)")
                    self.debugLog("Error: \(response.result.error ?? defaultValue as! Error)")
                    self.debugResponseData(response.data!)
                    completion(nil, response.response,response.result.error! as NSError, self.stringFromData(response.data!))
                    return
                }
                self.debugLog("Received HTTP \(response.response!.statusCode) from \(request.urlRequest!.httpMethod ?? defaultValue) to \(request.urlRequest!.url!)")
                self.debugResponseData(response.data!)
                guard let responseJSON = response.result.value else {
                    completion(nil, response.response, NSError(domain: "com.bitbat.invalidjsonerror", code: 10, userInfo: nil), nil)
                    self.debugLog("Invalid results information received from the service")
                        return
                }
                
                //let json = JSON.parse(responseJSON) in swift 2.3
                let json = JSON(responseJSON)
                
                completion(json, response.response, nil, nil)
        }
//        currentRequests.append(requestTask!)
        return requestTask!

    }
    func multipartFetch<T>(_ request: URLRequestConvertible, imageData: Data?, videoData: Data?, params: NSDictionary?, parseBlock: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        //Make request
        multipartTaskWithRequest(request, imageData: imageData, videoData: videoData, params: params) { [weak self] (json, response, error, errorDescription) in
            if let weakSelf = self {
                DispatchQueue.main.async() {
                    if let e = error {
                        if let res = response {
                            switch res.statusCode {
                            case 200:
                                break
                                //                            if let resource = parseBlock(json!) {
                                //                                completion(.Success(resource))
                                //                            } else {
                                //                                print("WARNING could not parse the following JSON as a \(T.self)")
                                //                                print(json!)
                                //                                completion(.UnexpectedResponse(json!))
                                //
                            //                            }
                            case 404: completion(.notFound)
                            case 400...499: completion(.clientError(res.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                            case 500...599: completion(.serverError(res.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                            default:
                                completion(.error(e))
                                BBDebugLog.DLog("received HTTP \(res.statusCode) which was not handled")
                            }
                            
                        } else {
                            completion(.error(e))
                        }
                    } else {
                        switch response!.statusCode {
                        case 200:
                            if let resource = parseBlock(json!) {
                                completion(.success(resource))
                            } else {
                                BBDebugLog.DLog("WARNING could not parse the following JSON as a \(T.self)")
                                BBDebugLog.DLog(json!)
                                completion(.unexpectedResponse(json!))
                                
                            }
                        case 404: completion(.notFound)
                        case 400...499: completion(.clientError(response!.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                        case 500...599: completion(.serverError(response!.statusCode, weakSelf.processRegistrationResponse(errorDescription)))
                        default:
                            BBDebugLog.DLog("received HTTP \(response!.statusCode) which was not handled")
                        }
                    }
                }
            }
        }
    }

    func multipartTaskWithRequest(_ request: URLRequestConvertible, imageData: Data?, videoData: Data?, params: NSDictionary?, completion: @escaping JsonTaskCompletionHandler) {
        Alamofire.upload(multipartFormData: { multipartFormData in
                if let data = imageData {
                    multipartFormData.append(data, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")

                    if let parameters: NSDictionary = params {
                        for (key, value) in parameters {
                            if let data = (value as! String).data(using: .utf8) {
                                multipartFormData.append(data, withName: key as! String )
                            }
                        }
                    }
                }
                if let data = videoData {
                    multipartFormData.append(data, withName: "file", fileName: "video.mp4", mimeType: "video/mp4")
                    
                    if let parameters: NSDictionary = params {
                        for (key, value) in parameters {
                            if let data = (value as! String).data(using: .utf8) {
                                multipartFormData.append(data, withName: key as! String )
                            }
                        }
                    }
                }
        }, with: request, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    let defaultValue = "defaultREquestValue"
                    upload.uploadProgress(closure: { (progress) in
                            //print progress
                    })
                    upload.validate()
//                    .validate(statusCode: 200..<300)
//                    .validate(contentType: ["application/json"])
                    upload.responseJSON { response in
                        guard response.result.isSuccess else {
                            self.debugLog("Received an error from HTTP \(request.urlRequest!.httpMethod ?? defaultValue) to \(request.urlRequest!.url!)")
                            self.debugLog("Error: \(response.result.error ?? defaultValue as! Error)")
                            self.debugResponseData(response.data!)
                            completion(nil, response.response,response.result.error! as NSError, self.stringFromData(response.data!))
                            return
                        }
                        self.debugLog("Received HTTP \(response.response!.statusCode) from \(request.urlRequest!.httpMethod ?? defaultValue) to \(request.urlRequest!.url!)")
                        self.debugResponseData(response.data!)
                        guard let responseJSON = response.result.value else {
                            completion(nil, response.response, NSError(domain: "com.bitbat.invalidjsonerror", code: 10, userInfo: nil), nil)
                            self.debugLog("Invalid results information received from the service")
                            return
                        }
                        
                        let json = JSON(responseJSON)
                        completion(json, response.response, nil, nil)
                    }
                case .failure( _):
                    completion(nil, nil, NSError(domain: "com.bitbat.invalidmultipartencodingerror", code: 11, userInfo: nil), nil)
                    self.debugLog("Invalid results information received from encoding multipart")
                }
            }
        )
    }
    
    func debugLog(_ msg: String) {
        guard loggingEnabled else { return }
        print(msg)
    }
    
    func debugResponseData(_ data: Data?) {
        guard loggingEnabled, let stringData = data else { return }
        if let body = stringFromData(stringData) {
            print(body)
        } else {
            print("<empty response>")
        }
    }
    
    func stringFromData(_ data: Data?) -> String?{
        guard let stringData = data else { return  nil}
        if let body = String(data: stringData, encoding: String.Encoding.utf8) {
            return body
        } else {
            return "<empty response>"
        }
    }
    
    func cancelAllRequests() {
        for request in self.currentRequests {
            request.cancel()
        }
        self.currentRequests = []
    }
    
    func downloadImage(_ url: String) -> UIImage? {
        let aUrl = URL(string: url)
        guard let data = try? Data(contentsOf: aUrl!),
            let image = UIImage(data: data) else {
                return nil
        }
        return image
    }
    
}
