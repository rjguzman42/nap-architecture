//
//  YoutubeVideoEvent.swift
//  bitbat
//
//  Created by Roberto Guzman on 5/15/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation

public enum PostsAnalyticsEvent: AnalyticsEvent {
    case createPost(userID: String, topic: String, postType: String, photo: Bool, video: Bool)
}
extension PostsAnalyticsEvent {
    var name: String {
        return String(describing: self)
    }
}
extension PostsAnalyticsEvent {
    var metadata: [String: String] {
        switch self {
        case .createPost(let userID, let topic, let postType, let photo, let video):
            return ["userID" : "\(userID)", "topic": "\(topic)", "postType": "\(postType)", "photo": "\(photo)", "video": "\(video)"]
        }
    }
}
