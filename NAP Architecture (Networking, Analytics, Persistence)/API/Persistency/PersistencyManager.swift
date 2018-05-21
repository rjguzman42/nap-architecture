//
//  PersistencyManager.swift
//  bitbat
//
//  Created by Roberto Guzman on 5/12/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation
import UIKit
import SSKeychain
import StoreKit


final class PersistencyManager {
    
    private var documents: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var cache: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    private enum Filenames {
        
    }
    
    init() {
    }
    
    //MARK: APP
    func appDidLaunch() {
        let defaults = [PersistRouter.launchCount: NSNumber(value: 0 as Int),
                        PersistRouter.firstLaunch: NSNumber(value: true as Bool),
            ] as [String : Any]
        UserDefaults.standard.register(defaults: defaults)
        UserDefaults.standard.set(true, forKey: PersistRouter.welcomeShown)
        if UserDefaults.standard.bool(forKey: PersistRouter.firstLaunch) {
            UserDefaults.standard.set(false, forKey: PersistRouter.firstLaunch)
            setAuthToken(nil)
            setUser(nil)
        }
        incrementAppOpenCount()
    }
    
    func incrementAppOpenCount() {
        var appOpenCount: Int = UserDefaults.standard.integer(forKey: PersistRouter.launchCount)
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: PersistRouter.launchCount)
        //check for review
        if #available(iOS 10.3, *) {
            switch appOpenCount {
            case 10:
                 SKStoreReviewController.requestReview()
            case _ where appOpenCount % 100 == 0 :
                SKStoreReviewController.requestReview()
            default:
            break
            }
        }
    }
    
    //MARK: Image
    func saveImage(_ image: UIImage, filename: String) {
        let url = cache.appendingPathComponent(filename)
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        try? data.write(to: url, options: [])
    }
    
    func saveImage(_ data: Data, filename: String) {
        let url = cache.appendingPathComponent(filename)
        try? data.write(to: url, options: [])
    }
    
    func getImage(with filename: String) -> UIImage? {
        let url = cache.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    //MARK: User
    func isLoggedIn() -> Bool {
        return getAuthToken() != nil
    }
    
    func logOut() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func setAuthToken(_ token: String?) {
        self.setSecureValue(value: token, key: PersistRouter.authToken)
    }
    
    func getAuthToken() -> String? {
        let token = getSecureValueForKey(PersistRouter.authToken)
        return token
    }
    
    func setUser(_ user: User?) {
        guard user != nil else {
            UserDefaults.standard.set(nil, forKey: PersistRouter.user)
            UserDefaults.standard.synchronize()
            return
        }
        do {
            let userJSON = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userJSON, forKey: PersistRouter.user)
            UserDefaults.standard.synchronize()
        } catch { }
        
        if let token = user!.authToken {
            setAuthToken(token)
        }
    }
    
    func getUser() -> User? {
        if let jsonData = UserDefaults.standard.data(forKey: PersistRouter.user) {
            do {
                let user = try JSONDecoder().decode(User.self, from: jsonData)
                return user
            } catch {}
        }
        return nil
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: PersistRouter.user)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: SSKeychain
    fileprivate func setSecureValue(value: String?, key: String?) {
        guard let pass = value else {
            SSKeychain.deletePassword(forService: PersistRouter.keychainAppService, account: key)
            return
        }
        SSKeychain.setPassword(pass, forService: PersistRouter.keychainAppService, account: key)
    }
    
    fileprivate func getSecureValueForKey(_ key: String!) -> String? {
        var error: NSError?
        
        let password = SSKeychain.password(forService: PersistRouter.keychainAppService, account: key, error: &error)
        if error != nil {
            return nil
        } else {
            return password
        }
    }
}

