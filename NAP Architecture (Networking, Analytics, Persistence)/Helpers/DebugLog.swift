//
//  DebugLog.swift
//  NetworkingCourse
//
//  Created by Roberto Guzman on 4/9/18.
//  Copyright © 2018 Roberto Guzman. All rights reserved.
//

import Foundation

open class DebugLog {
    open class func DLog<T>(_ message:T, function: String = #function) {
        #if DEBUG
        if let text = message as? String {
            print("\(function): \(text)")
        }
        #endif
    }
}
