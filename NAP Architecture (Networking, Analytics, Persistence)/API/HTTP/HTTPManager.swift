//
//  HTTPManager.swift
//  chefspot
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class HTTPManager {
    
    static let shared = HTTPManager()
    
    private init() {
    }
    
    //MARK: URLSession
    
    func getCollectionRequest<T: Codable>(_ clientType: APIClientType, _ routerPath: APIRouter, requestLoopCount: Int = 1, completion: @escaping (APIResult<[T]>) -> Void ) {
        //if we looped multiple times because of a 403 statusCode, let's get out!
        guard requestLoopCount < 3 else {
            completion(APIResult.refreshTokenExpired)
            return
        }
        
        do {
            try URLSession.shared.dataTask(with: routerPath.asURLRequest()as URLRequest) { (json, response, error) in
                DispatchQueue.main.async() {
                    //check if error
                    if let e = error {
                        if let res = response as? HTTPURLResponse {
                            switch res.statusCode {
                            case 200: break
                            case 403:
                                //accessToken expired; Let's refresh
                                self.refreshTokenWithRevoke(completion: {[weak self] authStatus in
                                    switch authStatus {
                                    case .accepted( _):
                                        //call original api with new token
                                        self?.getCollectionRequest(clientType, routerPath, requestLoopCount: requestLoopCount + 1, completion: completion)
                                        break
                                    case .denied:
                                        LibraryAPI.shared.logoutLocally()
                                        break
                                    default:
                                        break
                                    }
                                })
                            case 404: completion(APIResult.notFound)
                            case 400...499: completion(APIResult.clientError(res.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            case 500...599: completion(APIResult.serverError(res.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            default:
                                completion(APIResult.error(e as NSError))
                                DebugLog.DLog("received HTTP \(res.statusCode) which was not handled")
                            }
                            
                        } else {
                            completion(APIResult.error(e as NSError))
                        }
                    } else {
                        //no error, so check response status from server
                        if let response = response as? HTTPURLResponse {
                            switch response.statusCode {
                            case 200:
                                
                                //parse json
                                //                                do {
                                //                                    let parsedResult = try JSONSerialization.jsonObject(with: json!, options: .allowFragments) as! [T]
                                //                                    DebugLog.DLog("ParsedResult! : \(parsedResult)")
                                //                                    completion(APIResult.success(parsedResult))
                                //                                } catch {
                                //                                    completion(APIResult.unexpectedResponse)
                                //                                }
                                
                                //parse json with Decoder...needs to have all properties of T correct type with server
                                do {
                                    let decoder = JSONDecoder()
                                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                                    let jsonData = try decoder.decode([T].self, from: json!)
                                    completion(APIResult.success(jsonData))
                                } catch let jsonErr {
                                    DebugLog.DLog("WARNING could not parse the following JSON as a \(json!)")
                                    DebugLog.DLog(jsonErr)
                                    completion(APIResult.unexpectedResponse)
                                }
                            case 403:
                                //accessToken expired; Let's refresh
                                self.refreshTokenWithRevoke(completion: {[weak self] authStatus in
                                    switch authStatus {
                                    case .accepted( _):
                                        //call original api with new token
                                        self?.getCollectionRequest(clientType, routerPath, requestLoopCount: requestLoopCount + 1, completion: completion)
                                        break
                                    case .denied:
                                        LibraryAPI.shared.logoutLocally()
                                        break
                                    default:
                                        break
                                    }
                                })
                            case 404: completion(.notFound)
                            case 400...499: completion(APIResult.clientError(response.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            case 500...599: completion(APIResult.serverError(response.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            default:
                                DebugLog.DLog("received HTTP \(response.statusCode) which was not handled")
                            }
                        }
                        
                    }
                }
                }.resume()
        } catch {
            DebugLog.DLog("HTTPManager catch error")
        }
    }
    
    func getRequest<T: Codable>(_ clientType: APIClientType, _ routerPath: APIRouter, requestLoopCount: Int = 1, completion: @escaping (APIResult<T>) -> Void ) {
        //if we looped multiple times because of a 403 statusCode, let's get out!
        guard requestLoopCount < 3 else {
            completion(APIResult.refreshTokenExpired)
            return
        }
        
        do {
            try URLSession.shared.dataTask(with: routerPath.asURLRequest()as URLRequest) { (json, response, error) in
                DispatchQueue.main.async() {
                    //check if error
                    if let e = error {
                        if let res = response as? HTTPURLResponse {
                            switch res.statusCode {
                            case 200: break
                            case 403:
                                //accessToken expired; Let's refresh
                                self.refreshTokenWithRevoke(completion: {[weak self] authStatus in
                                    switch authStatus {
                                    case .accepted( _):
                                        //call original api with new token
                                        self?.getRequest(clientType, routerPath, requestLoopCount: requestLoopCount + 1, completion: completion)
                                        break
                                    case .denied:
                                        LibraryAPI.shared.logoutLocally()
                                        break
                                    default:
                                        break
                                    }
                                })
                            case 404: completion(APIResult.notFound)
                            case 400...499: completion(APIResult.clientError(res.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            case 500...599: completion(APIResult.serverError(res.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            default:
                                completion(APIResult.error(e as NSError))
                                DebugLog.DLog("received HTTP \(res.statusCode) which was not handled")
                            }
                            
                        } else {
                            completion(APIResult.error(e as NSError))
                        }
                    } else {
                        //no error, so check response status from server
                        if let response = response as? HTTPURLResponse {
                            switch response.statusCode {
                            case 200...299:
                                
                                //parse json
                                //                                do {
                                //                                    let parsedResult = try JSONSerialization.jsonObject(with: json!, options: .allowFragments) as! T
                                //                                    DebugLog.DLog("ParsedResult! : \(parsedResult)")
                                //                                    completion(APIResult.success(parsedResult))
                                //                                } catch {
                                //                                    completion(APIResult.unexpectedResponse)
                                //                                }
                                
                                //parse json with Decoder...needs to have all properties of T correct type with server
                                do {
                                    let decoder = JSONDecoder()
                                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                                    let jsonData = try decoder.decode(T.self, from: json!)
                                    completion(APIResult.success(jsonData))
                                } catch let jsonErr {
                                    DebugLog.DLog("WARNING could not parse the following JSON as a \(json!)")
                                    DebugLog.DLog(jsonErr)
                                    completion(APIResult.unexpectedResponse)
                                }
                            case 403:
                                //accessToken expired; Let's refresh
                                self.refreshTokenWithRevoke(completion: {[weak self] authStatus in
                                    switch authStatus {
                                    case .accepted( _):
                                        //call original api with new token
                                        self?.getRequest(clientType, routerPath, requestLoopCount: requestLoopCount + 1, completion: completion)
                                        break
                                    case .denied:
                                        LibraryAPI.shared.logoutLocally()
                                        break
                                    default:
                                        break
                                    }
                                })
                            case 404: completion(.notFound)
                            case 400...499: completion(APIResult.clientError(response.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            case 500...599: completion(APIResult.serverError(response.statusCode, self.processRegistrationResponse(error.debugDescription)))
                            default:
                                DebugLog.DLog("received HTTP \(response.statusCode) which was not handled")
                            }
                        }
                        
                    }
                }
                }.resume()
        } catch {
            DebugLog.DLog("HTTPManager catch error")
        }
    }
    
    
    //MARK: Alamofire
    
    func getMultiPartRequest<T>(_ clientType: APIClientType, _ request: URLRequestConvertible, imageData: Data?, imageKeyName: String = "file", videoData: Data? = nil, videoKeyName: String = "mov_file", audioData: Data? = nil, audioKeyName: String = "audio", params: NSDictionary? = nil, requestLoopCount: Int = 1, completion: @escaping (APIResult<T>) -> Void) {
        
        //if we looped multiple times because of a 403 statusCode, let's get out!
        guard requestLoopCount < 3 else {
            completion(APIResult.refreshTokenExpired)
            return
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            //append data and parameters to multiForm
            if let data = imageData {
                multipartFormData.append(data, withName: imageKeyName, fileName: "png", mimeType: "image/png")
            }
            if let audio = audioData {
                multipartFormData.append(audio, withName: audioKeyName, fileName: "mp3", mimeType: "application/octet-stream")
            }
            if let video = videoData {
                multipartFormData.append(video, withName: videoKeyName, fileName: "mov_file", mimeType: "video/quicktime")
            }
            
            if let parameters: NSDictionary = params {
                for (key, value) in parameters {
                    if let data = (value as! String).data(using: .utf8) {
                        multipartFormData.append(data, withName: key as! String)
                    }
                }
            }
            
        }, with: request, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    DebugLog.DLog(progress)
                })
                upload.responseJSON { response in
                    switch(response.result){
                    case .success:
                        if let statusCode = response.response?.statusCode {
                            if AppUtility.shared.checkStatusCode(statusCode: statusCode){
                                if let response = response.value as? T {
                                    DebugLog.DLog("SUCCESS MultiFormData Response : \(response)")
                                    completion(APIResult.success(response))
                                }
                            } else if AppUtility.shared.unAuthorizedCode(statusCode: statusCode){
                                completion(APIResult.unexpectedResponse)
                            } else {
                                if let response = response.value as? T {
                                    completion(APIResult.success(response))
                                }
                            }
                        }
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            switch statusCode {
                            case 200: break
                            case 403:
                                //accessToken expired; Let's refresh
                                self.refreshTokenWithRevoke(completion: {[weak self] authStatus in
                                    switch authStatus {
                                    case .accepted( _):
                                        //call original api with new token
                                        self?.getMultiPartRequest(clientType, request, imageData: imageData, imageKeyName: imageKeyName, videoData: videoData, videoKeyName: videoKeyName, audioData: audioData, audioKeyName: audioKeyName, params: params, requestLoopCount: requestLoopCount + 1, completion: completion)
                                        break
                                    case .denied:
                                        LibraryAPI.shared.logoutLocally()
                                        break
                                    default:
                                        break
                                    }
                                })
                            case 404: completion(APIResult.notFound)
                            case 400...499: completion(APIResult.clientError(statusCode, self.processRegistrationResponse(error.localizedDescription)))
                            case 500...599: completion(APIResult.serverError(statusCode, self.processRegistrationResponse(error.localizedDescription)))
                            default:
                                completion(APIResult.error(error as NSError))
                                DebugLog.DLog("received HTTP \(statusCode) which was not handled")
                            }
                        }
                        if error._code == NSURLErrorTimedOut {
                            completion(APIResult.timedOut(error as NSError))
                        }
                    }
                }
            case .failure(let encodingError):
                completion(APIResult.error(encodingError as NSError))
            }
        })
    }
    
    //MARK: Auth
    
    fileprivate func refreshTokenWithRevoke(completion: @escaping ((AuthStatus<String?>) -> Void)) {
        let authService = AuthService.shared
        authService.refreshTokenWithRevoke(completion: completion)
    }
    
    //MARK: Response
    
    func processRegistrationResponse(_ resultString: String?) -> String{
        guard let result = resultString else {return ""}
        DebugLog.DLog(result)
        return Constants.Errors.generalError
    }
    
}
