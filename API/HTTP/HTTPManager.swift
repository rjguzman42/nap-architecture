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
    
    func getCollectionRequest<T: Codable>(_ clientType: APIClientType, _ routerPath: APIRouter, completion: @escaping (APIResult<[T]>) -> Void ) {
        do {
            try URLSession.shared.dataTask(with: routerPath.asURLRequest()as URLRequest) { (json, response, error) in
                DispatchQueue.main.async() {
                    //check if error
                    if let e = error {
                        if let res = response as? HTTPURLResponse {
                            switch res.statusCode {
                            case 200: break
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
    
    func getRequest<T: Codable>(_ clientType: APIClientType, _ routerPath: APIRouter, completion: @escaping (APIResult<T>) -> Void ) {
        do {
            try URLSession.shared.dataTask(with: routerPath.asURLRequest()as URLRequest) { (json, response, error) in
                DispatchQueue.main.async() {
                    //check if error
                    if let e = error {
                        if let res = response as? HTTPURLResponse {
                            switch res.statusCode {
                            case 200: break
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
    
    func processRegistrationResponse(_ resultString: String?) -> String{
        guard let result = resultString else {return ""}
        DebugLog.DLog(result)
        return Constants.APIMessage.generalError
    }
    
    
    //MARK: Image
    
    func downloadImage(_ url: String) -> UIImage? {
        let aUrl = URL(string: url)
        guard let data = try? Data(contentsOf: aUrl!),
            let image = UIImage(data: data) else {
                return nil
        }
        return image
    }
    
    func downloadImageWithPath(path: String, completion: @escaping (UIImage?, Data?) -> Void) {
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: path), options: .continueInBackground, progress: nil, completed: {(image:UIImage?, data:Data?, error:Error?, finished:Bool) in
            completion(image, data)
        })
    }
    
}
