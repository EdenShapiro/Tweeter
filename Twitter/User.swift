//
//  User.swift
//  Twitter
//
//  Created by Eden on 9/26/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class User: NSObject {
	var name: String?
	var screenName: String?
	var profileURL: URL?
	var profileDescription: String?
	var followersCount: Int?
	var followingCount: Int?
	var tweetCount: Int?
	var backgroundColor: String?
	var backgroundImageURL: URL?
	var favoritesCount: Int?
	
	var dict: [String: Any?]
	
	
	init(dictionary: [String: Any?]){
		dict = dictionary
		name = dictionary["name"] as? String
		screenName = dictionary["screen_name"] as? String
		if let urlString = dictionary["profile_image_url_https"] as? String {
			profileURL = URL(string: urlString)
		}
		profileDescription = dictionary["description"] as? String
		followersCount = dictionary["followers_count"] as? Int
		followingCount = dictionary["friends_count"] as? Int
		tweetCount = dictionary["statuses_count"] as? Int
		backgroundColor = dictionary["profile_background_color"] as? String
		if let backgroundUrlString = dictionary["profile_banner_url"] as? String {
			print(name ?? "no name")
			//profile_background_image_url_https
			print(backgroundUrlString)
			backgroundImageURL = URL(string: backgroundUrlString)
		}
		favoritesCount = dictionary["favourites_count"] as? Int

	}
	
	static let userDidLogoutNotificationName = Notification.Name("UserDidLogout")
	
	static var _currentUser: User?
	
	class var currentUser: User? {
		get {
			if _currentUser == nil {
				let defaults = UserDefaults.standard
				if let userData = defaults.object(forKey: "currentUserData") as? Data {
					let dict = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String: Any?]
					_currentUser = User(dictionary: dict)
				}
			}
			
			return _currentUser
		}
		set(user){
			_currentUser = user
			let defaults = UserDefaults.standard
			if let user = user {
				let data = try! JSONSerialization.data(withJSONObject: user.dict, options: [])
				defaults.set(data, forKey: "currentUserData")

			} else {
				defaults.removeObject(forKey: "currentUserData")

			}
			defaults.synchronize()
		}
	}
}
