//
//  Tweet.swift
//  Twitter
//
//  Created by Eden on 9/26/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class Tweet: NSObject {
	var id: Int?
	var text: String?
	var createdAt: Date?
	var retweetCount: Int = 0
	var favoritesCount: Int = 0
	var replyCount: Int = 0
	var favorited: Bool = false
	var retweeted: Bool = false
	var retweetStatus: Tweet?
	var tweeter: User?
	
	init(dict: [String: Any?]){
		id = dict["id"] as? Int
		
		if let dic = dict["retweeted_status"] {
			print("retweeted_status dic")
			retweetStatus = Tweet(dict: dic as! [String : Any?])
			print("retweetStatus: \(retweetStatus)")
		}
		
		text = dict["text"] as? String
		retweetCount = (dict["retweet_count"] as? Int) ?? 0
		retweeted = dict["retweeted"] as! Bool
		favoritesCount = (dict["favorite_count"] as? Int) ?? 0
		print("favorites count: \(favoritesCount)")
		favorited = dict["favorited"] as! Bool
		if let replyCount = dict["reply_count"] as? Int {
			print("there is a replycount")
			self.replyCount = replyCount
		} else {
			print("there is NO reply count")
		}
		replyCount = (dict["reply_count"] as? Int) ?? 0
		if let timeStampString = dict["created_at"] as? String {
			print(timeStampString)
			
			let formatter = DateFormatter()
			formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
			
			createdAt = formatter.date(from: timeStampString)
			

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
