//
//  AppUtility.swift
//  chefspot
//
//  Created by Roberto Guzman on 7/6/18.
//  Copyright © 2018 Fortytwo Sports. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import MapKit

struct AppUtility {
    static let sharedInstance = AppUtility()
    
    
    //MARK: User Feedback
    
    func hapticOnce() {
        if #available(iOS 10.0, *) {
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()
        } else {
        }
    }
    
    func showAlert(_ title: String? = "", message: String? = "", vc: UIViewController? = nil) {
        var vc: UIViewController? = vc
        if vc == nil {
            vc = getCurrentViewController()
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Alerts.dismissAlert, style: .default, handler: nil))
        vc?.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithHandler(_ title: String, message: String, approveTitle: String, dismissTitle: String, vc: UIViewController? = nil, completion: @escaping (_ alert: UIAlertAction, _ dismissed: Bool) -> Void) {
        var vc: UIViewController? = vc
        if vc == nil {
            vc = getCurrentViewController()
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissTitle, style: .default, handler: {(alert: UIAlertAction!) in
            completion(alert, true)
        }))
        alert.addAction(UIAlertAction(title: approveTitle, style: .default, handler: {(alert: UIAlertAction!) in
            completion(alert, false)
        }))
        vc?.present(alert, animated: true, completion: nil)
    }
    
    func handleAPIResultError<T>(_ result: APIResult<T>) {
        switch result {
        case .serverError(_, let errMsg):
            DebugLog.DLog(errMsg)
            self.showAlert(Constants.Alerts.generalServerErrorTitle, message: Constants.Alerts.generalServerErrorMessage)
            break
        case .clientError(_, let errMsg):
            DebugLog.DLog(errMsg)
            self.showAlert(Constants.Alerts.generalServerErrorTitle, message: Constants.Alerts.generalServerErrorMessage)
            break
        case .error(let errMsg):
            DebugLog.DLog(errMsg)
            self.showAlert(Constants.Alerts.generalServerErrorTitle, message: Constants.Alerts.generalServerErrorMessage)
            break
        case .persistencyError(let errMsg):
            DebugLog.DLog(errMsg)
            self.showAlert(Constants.Alerts.generalPersistencyErrorTitle, message: Constants.Alerts.generalPersistencyErrorMessage)
            break
        case .unexpectedResponse:
            self.showAlert(Constants.Alerts.generalServerErrorTitle, message: Constants.Alerts.generalServerErrorMessage)
            break
        case .notFound:
            self.showAlert(Constants.Alerts.generalServerErrorTitle, message: Constants.Alerts.generalServerErrorMessage)
            break
        default:
            DebugLog.DLog("oops! We somehow sent a (success / client error result) to our handle server error function")
            self.showAlert(Constants.Alerts.generalServerErrorTitle, message: Constants.Alerts.generalServerErrorMessage)
            break
        }
    }
    
    
    //MARK: System
    
    func getCurrentViewController() -> UIViewController? {
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        return keyboardFrame!.height
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func hideStatusBar(_ hide: Bool) {
        if let keyWindow = UIApplication.shared.keyWindow {
            if hide {
                keyWindow.windowLevel = UIWindowLevelStatusBar + 1
            } else {
                keyWindow.windowLevel = UIWindowLevelStatusBar - 1
            }
        }
    }
    
    func clearControllers() {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController  as? UINavigationController{
            rootVC.dismiss(animated: false, completion: nil)
            let controller = GetStartedVC()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.makeKeyAndVisible()
            UIView.transition(with: appDelegate.window!, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {() -> Void in
                
                appDelegate.window!.rootViewController = controller
                
            }, completion: nil)
        }
    }
    
    func getCurrentDateAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        return date
    }
    
    func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func callNumber(_ phoneNumber: String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            openURL(phoneCallURL)
        }
    }
    
    func sendUserToDirections(latitude: Double, longitude: Double, directionsName: String) {
        //TODO: Add user default preference that chooses the maps you prefer
        
        //google maps
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(String(latitude)),\(String(longitude))&directionsmode=driving")!)
        } else {
            //apple maps
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
            mapItem.name = directionsName
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
    
    
    //MARK: UI
    
    func setupBaseUI() {
        //navigation bar style
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.titleTextAttributes = [
            NSAttributedStringKey.font: Theme.Fonts.titleBold.font,
            NSAttributedStringKey.foregroundColor: Theme.Colors.primaryText.color
        ]
        navBarAppearance.barStyle = UIBarStyle.default
        navBarAppearance.barTintColor = Theme.Colors.navBar.color
        navBarAppearance.tintColor = Theme.Colors.primaryText.color
        
        //set below for transparent navbar
        navBarAppearance.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        //removes navBar border
        navBarAppearance.shadowImage = UIImage()
        
        
        //tool bar style
        let toolBarAppearance = UIToolbar.appearance()
        toolBarAppearance.barStyle = UIBarStyle.default
        toolBarAppearance.barTintColor = Theme.Colors.toolBar.color
        toolBarAppearance.tintColor = Theme.Colors.darkRoseRed.color
        toolBarAppearance.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
        toolBarAppearance.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolBarAppearance.backgroundColor = Theme.Colors.toolBar.color
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barStyle = UIBarStyle.default
        tabBarAppearance.barTintColor = Theme.Colors.navBar.color
        toolBarAppearance.tintColor = Theme.Colors.darkRoseRed.color
        toolBarAppearance.backgroundColor = Theme.Colors.navBar.color
        
        
        //status bar style
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .clear
        }
    }
    
    func getSizeToFitString(text: String, font: UIFont) -> CGSize {
        let size = CGSize(width: 150, height: 44)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: font], context: nil)
        return CGSize(width: estimatedFrame.width + 30, height: 25)
    }
    
    func groupBy<Type, MemberType>(_ collection: [Type], member: (Type) -> MemberType) -> [MemberType: [Type]] {
        var dict = [MemberType:[Type]]()
        for x in collection {
            let member = member(x)
            if dict[member] == nil {
                dict[member] = []
            }
            dict[member]!.append(x)
        }
        return dict
    }
    
    func getDecimalFromDouble(_ number: Double) -> Double {
        let x: Double = number
        let numberOfPlaces: Double = 1.0
        let powerOfTen: Double = pow(10.0, numberOfPlaces)
        let targetedDecimalPlaces: Double = round((x.truncatingRemainder(dividingBy: 1.0)) * powerOfTen) / powerOfTen
        return targetedDecimalPlaces
    }
    
    func removeFormatFromNumber(_ formattedNumber: String) -> String {
        let number = formattedNumber.filter {!Constants.Strings.generalInputCharactersNotAllowed.contains($0)}
        return number
    }
    
    
    //MARK: Validation
    
    
    func checkAuthCredentials(nameInput: UserInput, profileImageView: UIImageView) -> Bool {
        
        let charSet = CharacterSet.whitespaces
        var testing:NSString = NSString()
        var trimmedTestingString:NSString = NSString()
        
        
        //userName is not empty
        testing = nameInput.text! as NSString
        trimmedTestingString =  testing .trimmingCharacters(in: charSet) as NSString
        if(trimmedTestingString .isEqual(to: "")) {
            showAlert("", message: Constants.Alerts.enterUserName)
            return false
        }
        
        //profileImageView has image
        guard profileImageView.image != nil else {
            showAlert("", message: Constants.Alerts.enterProfileImage)
            return false
        }
        
        return true
    }
}
