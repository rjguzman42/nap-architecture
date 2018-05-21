//
//  LibraryAPI.swift
//  bitbat
//
//  Created by Roberto Guzman on 3/18/18.
//  Copyright © 2016 fortyTwoSports. All rights reserved.
//

import Foundation
import Alamofire

class LibraryAPI {
    
    static let sharedLibraryAPI = LibraryAPI()
    private let httpManager = HTTPManager()
    private let persistencyManager = PersistencyManager()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(downloadImage(with:)), name: .DownloadImage, object: nil)
    }
    
    func fetchUsers(_ completion: @escaping (APIResult<[User]>) -> Void) {
        httpManager.fetchCollection(APIRouter.fetchUsers, rootKey: "exist", completion: completion)
    }
    
    @objc func downloadImage(with notification: Notification) {
        guard let userInfo = notification.userInfo,
            let imageView = userInfo["imageView"] as? UIImageView,
            let urlPath = userInfo["urlPath"] as? String,
            let persist = userInfo["persist"] as? Bool,
            let filename = URL(string: urlPath)?.lastPathComponent else {
                return
        }
        //check if image is stored locally first
        if let savedImage = persistencyManager.getImage(with: filename) {
            imageView.image = savedImage
            return
        }
        
        //download image and persist
        DispatchQueue.global().async {
            let downloadedImage = self.httpManager.downloadImage(urlPath) ?? UIImage()
            DispatchQueue.main.async {
                imageView.image = downloadedImage
                if persist {
                    self.persistencyManager.saveImage(downloadedImage, filename: filename)
                }
            }
        }
    }
}
