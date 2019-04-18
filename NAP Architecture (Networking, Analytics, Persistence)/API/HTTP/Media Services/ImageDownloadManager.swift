//
//  ImageDownloadManager.swift
//  appName
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation
import SDWebImage
import Kingfisher

class ImageDownloadManager {
    
    init() {
    }
    
    func downloadImage(url: URL?, type: ImageClientType, completion: @escaping (UIImage?, Data?, Error?) -> Void) {
        guard let url = url else {
            completion(nil, nil, APIError.unexpectedResponse)
            return
        }
        switch type {
        case .sdWebImage:
            downloadImageWithSDWebImage(url: url, completion: completion)
            break
        case .kingFisher:
            downloadImageWithKingfisher(url: url, completion: completion)
            break
        }
        
    }
    
    //sdWebImage
    fileprivate func downloadImageWithSDWebImage(url: URL?, completion: @escaping (UIImage?, Data?, Error?) -> Void) {
        guard let url = url else {
            completion(nil, nil, APIError.unexpectedResponse)
            return
        }
        SDWebImageDownloader.shared.downloadImage(with: url, options: .continueInBackground, progress: nil, completed: {(image:UIImage?, data:Data?, error:Error?, finished:Bool) in
            completion(image, data, error)
        })
    }
    
    //kingFisher
    fileprivate func downloadImageWithKingfisher(url: URL?, completion: @escaping (UIImage?, Data?, Error?) -> Void) {
        guard let url = url else {
            completion(nil, nil, APIError.unexpectedResponse)
            return
        }
        let accessToken = PersistencyManager.shared.getSecureValue(key: PersistencyRouter.accessToken)
        if accessToken != nil {
            let modifier = AnyModifier { request in
                var r = request
                r.setValue("Bearer \(String(describing: accessToken!))", forHTTPHeaderField: "Authorization")
                
                return r
            }
            let manager = KingfisherManager.shared.downloader
            manager.downloadImage(with: url, options: [.requestModifier(modifier)], progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    completion(value.image, value.originalData, nil)
                case .failure(let error):
                    DebugLog.DLog(error)
                    completion(nil, nil, NSError(domain: error.errorDescription ?? "", code: error.errorCode, userInfo: error.errorUserInfo))
                }
            }
        }
    }
}
