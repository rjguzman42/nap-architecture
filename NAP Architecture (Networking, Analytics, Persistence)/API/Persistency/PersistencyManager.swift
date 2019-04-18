//
//  PersistencyManager.swift
//  chefspot
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SSKeychain
import StoreKit

class PersistencyManager {
    
    static let sharedInstance = PersistencyManager()
    
    private var documents: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var cache: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext!
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    init(modelName: String = "ChefSpot") {
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    
    //MARK: APP
    
    func appDidLaunch() {
        var firstLaunch: Bool = false
        
        //register defaults
        let defaults = [PersistRouter.firstLaunch: NSNumber(value: true as Bool),
                        PersistRouter.mapLatitude: 25.7617,
                        PersistRouter.mapLongitude: 80.1918,
                        PersistRouter.mapLatitudeSpan: 90.0,
                        PersistRouter.mapLongitudeSpan: 180.0
            ] as [String : Any]
        UserDefaults.standard.register(defaults: defaults)
        if UserDefaults.standard.bool(forKey: PersistRouter.firstLaunch) {
            UserDefaults.standard.set(false, forKey: PersistRouter.firstLaunch)
            deleteAllSecureValues()
            firstLaunch = true
        }
        
        //core data
        loadCoreData(completion: { [weak self] in
            if firstLaunch {
                self?.registerCoreDataDefaults()
            }
        })
        
        //app store
        incrementAppOpenCount()
    }
    
    func incrementAppOpenCount() {
        var appOpenCount: Int = UserDefaults.standard.integer(forKey: PersistRouter.launchCount)
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: PersistRouter.launchCount)
        print("appOpenCount: \(appOpenCount)")
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
    
    
    //MARK: CoreData
    
    func registerCoreDataDefaults() {
        let savedSearchTerms = ["Breakfast" : "ic_heart_full", "Lunch" : "ic_heart_full", "Dinner" : "ic_heart_full", "Coffee & Tea" : "ic_heart_full", "Smoothie" : "ic_heart_full"]
        let popularSearchTerms = ["Breakfast" : "ic_heart_full", "Lunch" : "ic_heart_full", "Dinner" : "ic_heart_full", "Coffee & Tea" : "ic_heart_full", "Smoothie" : "ic_heart_full", "Tacos" : "ic_heart_full", "Pizza" : "ic_heart_full"]
        var order: Int = 0
        for (name, imageName) in savedSearchTerms {
            let term = SearchTerm(context: viewContext)
            term.name = name
            term.imageName = imageName
            term.type = SearchTermType.saved.rawValue
            term.order = Int32(order)
            order += 1
        }
        order = 100
        for (name, imageName) in popularSearchTerms {
            let term = SearchTerm(context: viewContext)
            term.name = name
            term.imageName = imageName
            term.type = SearchTermType.popular.rawValue
        }
        saveCoreData()
    }
    
    func loadCoreData(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    func saveCoreData() {
        do {
            try viewContext.save()
        } catch {
            DebugLog.DLog("Couldn't save core data")
        }
    }
    
    func removeCoreDataObject(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveCoreData()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else {
            DebugLog.DLog("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
    
    func getCoreDataRequest<T: NSManagedObject>(_ predicates: NSPredicate?, _ sortDescriptors: [NSSortDescriptor] = [], completion: @escaping (APIResult<T>) -> Void ) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        if predicates != nil {
            fetchRequest.predicate = predicates
        }
        if sortDescriptors != [] {
            fetchRequest.sortDescriptors = sortDescriptors
        }

        do {
            let results = try viewContext.fetch(fetchRequest)
            if results.count > 0 {
                completion(APIResult.success(results.first!))
            }
        } catch {
            completion(APIResult.persistencyError(processRegistrationResponse(error.localizedDescription)))
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func getCoreDataCollectionRequest<T: NSManagedObject>(_ predicates: NSPredicate?, _ sortDescriptors: [NSSortDescriptor] = [], completion: @escaping (APIResult<[T]>) -> Void ) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        if predicates != nil {
            fetchRequest.predicate = predicates
        }
        if sortDescriptors != [] {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            completion(APIResult.success(results))
        } catch {
            completion(APIResult.persistencyError(processRegistrationResponse(error.localizedDescription)))
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
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
    
    
    //MARK: Secured Values - SSKeychain
    
    func setSecureValue(value: String?, key: String?) {
        guard let pass = value else {
            SSKeychain.deletePassword(forService: PersistencyRouter.keychainAppService, account: key)
            return
        }
        SSKeychain.setPassword(pass, forService: PersistencyRouter.keychainAppService, account: key)
    }
    
    func getSecureValue(key: String) -> String? {
        var error: NSError?
        
        let password = SSKeychain.password(forService: PersistencyRouter.keychainAppService, account: key, error: &error)
        if error != nil {
            return nil
        } else {
            return password
        }
    }
    
    func deleteSecureValue(key: String) {
        SSKeychain.deletePassword(forService: PersistencyRouter.keychainAppService, account: key)
    }
    
    func deleteAllSecureValues() {
        SSKeychain.deletePassword(forService: PersistencyRouter.keychainAppService, account: PersistencyRouter.accessToken)
        SSKeychain.deletePassword(forService: PersistencyRouter.keychainAppService, account: PersistencyRouter.refreshToken)
    }

    
    //MARK: Response
    
    func processRegistrationResponse(_ resultString: String?) -> String{
        guard let result = resultString else {return ""}
        DebugLog.DLog(result)
        return Constants.APIMessage.persistencyError
    }
    
    
    //MARK: Exit
    
    func clearAllDataLocally() {
        clearAllUserDefaults()
        clearAllCoreData()
    }
    
    func clearAllUserDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    func clearAllCoreData() {
        
    }
}
