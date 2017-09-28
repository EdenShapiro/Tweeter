//
//  Tweet.swift
//  Twitter
//
//  Created by Eden on 9/26/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class Tweet: NSObject {
	var text: String?
	var createdAt: Date?
	var retweetCount: Int = 0
	var favoritesCount: Int = 0
	
	init(dict: [String: Any?]){
		text = dict["text"] as? String
		retweetCount = (dict["retweet_count"] as? Int) ?? 0
		favoritesCount = (dict["favourites_count"] as? Int) ?? 0
		
		if let timeStampString = dict["created_at"] as? String {
			let formatter = DateFormatter()
			formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
			createdAt = formatter.date(from: timeStampString)
		}
	}
	
	class func tweetsWithArray(dicts: [[String: Any?]]) -> [Tweet] {
		var tweets = [Tweet]()
		for dict in dicts {
			let tweet = Tweet(dict: dict)
			tweets.append(tweet)
		}
		return tweets
	}
	
}
