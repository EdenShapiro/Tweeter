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
	var createdAt: String?
	var retweetCount: Int = 0
	var favoritesCount: Int = 0
	var replyCount: Int = 0
	var favorited: Bool = false
	var retweeted: Bool = false
	var replied: Bool = false
	var tweeter: User?
	
	init(dict: [String: Any?]){
		text = dict["text"] as? String
		retweetCount = (dict["retweet_count"] as? Int) ?? 0
		favoritesCount = (dict["favourites_count"] as? Int) ?? 0
		
		if let timeStampString = dict["created_at"] as? String {
			print(timeStampString)
			
			let formatter = DateFormatter()
			formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
			
			let date = formatter.date(from: timeStampString)
			formatter.dateFormat = "M/dd/yy"
			createdAt = formatter.string(from: date!)

//			formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
//			let date = formatter.date(from: timeStampString)
//			formatter.dateFormat = "M/dd/yy"
//			let str = formatter.string(from: date!)
//			createdAt = formatter.date(from: str)

//
//			
//			let dateFormatter = DateFormatter()
//			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
//			let date = dateFormatter.date(from: date)
//			dateFormatter.dateFormat = "yyyy-MM-dd"
//			return  dateFormatter.string(from: date!)
			
			
		}
		tweeter = User(dictionary: (dict["user"] as! [String : Any?]))
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
