//
//  YouTubeVideoAnalyticsEvent.swift
//  bitbat
//
//  Created by Roberto Guzman on 5/15/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation

struct YouTubeVideoAnalyticsEvent: AnalyticsEvent {
    var name: String
    var metadata: [String : String]
    
    private init(name: String, metadata: [String: String] = [:]) {
        self.name = name
        self.metadata = metadata
    }
    
    static func playVideo(userID: String, post: BBPost, appLocation: String) -> AnalyticsEvent {
        let postID: String = post.postid ?? ""
        let creatorName: String = post.creatorName ?? ""
        var topic = ""
        if(post.topics?[0] != nil) {
            if(post.topics?[0].name != "") {
                topic = (post.topics?[0].name)!
            }
        }
        let metadata: [String : String] = ["userID" : "\(userID)", "postID": "\(postID)", "creatorName": "\(creatorName)", "topic": "\(topic)", "appLocation": "\(appLocation)"]
        return YouTubeVideoAnalyticsEvent(name: "playYoutubeVideo", metadata: metadata)
    }
}
