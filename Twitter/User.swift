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
	var tagLine: String?
	var dict: [String: Any?]
	
	init(dictionary: [String: Any?]){
		dict = dictionary
		name = dictionary["name"] as? String
		screenName = dictionary["screen_name"] as? String
		if let urlString = dictionary["profile_image_url_https"] as? String {
			profileURL = URL(string: urlString)
		}
		tagLine = dictionary["description"] as? String
	}
	
	static let userDidLogoutNotificationName = Notification.Name("UserDidLogout")
	
	static var _currentUser: User?
	
	class var currentUser: User? {
		get {
			if _currentUser == nil {
				let defaults = UserDefaults.standard
				let userData = defaults.object(forKey: "currentUserData") as? Data
				if let userData = userData {
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
//				defaults.set(nil, forKey: "currentUserData")
				defaults.removeObject(forKey: "currentUserData")

			}
			
			defaults.synchronize()
		}
	}
}
