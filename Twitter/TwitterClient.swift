//
//  TwitterClient.swift
//  Twitter
//
//  Created by Eden on 9/26/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

let consumerKey = "L1n2oYOQBvRO73TY8kO3Kslon"
let consumerSecret = "2LYsvKaooUAOvZVRysbueF0zjFwF6zP6IonKTgWZUIUKHRNXRc"
let baseUrl = "https://api.twitter.com"

class TwitterClient: BDBOAuth1SessionManager {
	
	static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string:
  baseUrl), consumerKey: consumerKey, consumerSecret:
  consumerSecret)!
	
	var loginSuccess: (() -> ())?
	var loginFailure: ((Error) -> ())?
	
	
	// User login
	func login(success: @escaping () -> (), failure: @escaping (Error) -> ()){
		loginSuccess = success
		loginFailure = failure
		
		deauthorize()
		fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterclone://oauth"), scope: nil, success: {(requestToken: BDBOAuth1Credential?) -> Void in
			print("I got a token!")
			guard let token = requestToken?.token else {
				return
			}
			
			let url = URL(string: "\(baseUrl)/oauth/authorize?oauth_token=\(token)")
			UIApplication.shared.open(url!, options: [:], completionHandler: nil)
			
		}) {(error: Error?) -> Void in
			print("Error: \(error)")
			self.loginFailure?(error!)
		}
	}
	
	// Second part of login function
	func handleOpenURL(url: URL){
		let requestToken = BDBOAuth1Credential(queryString: url.query)
		
		fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
			print("I got access token!")
			
			self.currentAccount(success: { (user: User) in
				User.currentUser = user
				self.loginSuccess?()
			}, failure: { (error: Error) in
				self.loginFailure?(error)
			})
			
			
		}, failure: { (error: Error?) in
			print("Error getting access token: \(error.debugDescription)")
			self.loginFailure?(error!)
		})
	}
	
	// Get user's home timeline
	func homeTimeline(maxID: Int?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
		
		var params: [String: Any]?
		if let max = maxID {
			params = ["max_id": "\(max)", "include_entities": "true"]
			
		}
		get("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
			
			let dicts = response as! [[String: Any?]]
			let tweets = Tweet.tweetsWithArray(dicts: dicts)
			success(tweets)
			
		}, failure: { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		})
	}
	
	// Get current user credentials
	func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
		// Get user info
		get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
			
			print("account: \(response)")
			let userDict = response as! [String: Any?]
			let user = User(dictionary: userDict)
			success(user)
			
		}, failure: { (task: URLSessionDataTask?, error: Error) in
			failure(error)
			print("Error verifying credentials: \(error.localizedDescription)")
		})
	}
	
	// Logout
	func logout(){
		User.currentUser = nil
		deauthorize()
		NotificationCenter.default.post(name: User.userDidLogoutNotificationName, object: nil)
		
	}
	
	// Post a tweet
	//	POST https://api.twitter.com/1.1/statuses/update.json?status=Maybe%20he%27ll%20finally%20find%20his%20keys.%20%23peterfalk
	func postTweet(status: String, success: @escaping (Tweet) -> (), failure:
		@escaping (Error) -> ()) {
		
		let params: [String: Any] = ["status": status]
		
		post("1.1/statuses/update.json", parameters: params, progress: nil, success: {
			(task: URLSessionDataTask, response: Any?) in
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)
		}) { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		}
	}
	
	// Retweet 
	//	POST https://api.twitter.com/1.1/statuses/retweet/243149503589400576.json

	func retweet(tweetID: Int, success: @escaping (Tweet) -> (), failure:
		@escaping (Error) -> ()) {
		
		let params: [String: Any] = ["id": "\(tweetID)"]
		
		post("1.1/statuses/retweet.json", parameters: params, progress: nil, success: {
			(task: URLSessionDataTask, response: Any?) in
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)

		}) { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		}
	}
	
	// Unretweet
	//POST https://api.twitter.com/1.1/statuses/unretweet/241259202004267009.json
	func unretweet(tweetID: Int, success: @escaping (Tweet) -> (), failure:
		@escaping (Error) -> ()) {
		
		let params: [String: Any] = ["id": "\(tweetID)"]
		
		post("1.1/statuses/unretweet.json", parameters: params, progress: nil, success: {
			(task: URLSessionDataTask, response: Any?) in
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)

		}) { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		}
	}
	
	// Favorite
	//	POST https://api.twitter.com/1.1/favorites/create.json?id=243138128959913986
	func favorite(tweetID: Int, success: @escaping (Tweet) -> (), failure:
		@escaping (Error) -> ()) {
		
		let params: [String: Any] = ["id": "\(tweetID)"]
		
		post("1.1/favorites/create.json", parameters: params, progress: nil, success: {
			(task: URLSessionDataTask, response: Any?) in
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)

		}) { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		}
	}
	
	// Unfavorite
	//	POST https://api.twitter.com/1.1/favorites/destroy.json?id=243138128959913986
	func unfavorite(tweetID: Int, success: @escaping (Tweet) -> (), failure:
		@escaping (Error) -> ()) {
		
		let params: [String: Any] = ["id": "\(tweetID)"]
		
		post("1.1/favorites/destroy.json", parameters: params, progress: nil, success: {
			(task: URLSessionDataTask, response: Any?) in
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)

		}) { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		}
	}
	
	// Reply to a tweet
	//	POST
	func reply(status: String, replyToTweetWithId: Int, success: @escaping (Tweet) -> (), failure:
		@escaping (Error) -> ()) {
		
		let params: [String: Any] = ["status": status, "in_reply_to_status_id": "\(replyToTweetWithId)"]
		
		post("1.1/statuses/update.json", parameters: params, progress: nil, success: {
			(task: URLSessionDataTask, response: Any?) in
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)
		}) { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		}
	}
	
	// Fetch tweet with ID
	//	GET https://api.twitter.com/1.1/statuses/show.json?id=210462857140252672
	func getTweetWithId(tweetID: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
		
		let params: [String: Any] = ["id": "\(tweetID)", "include_my_retweet": "true"]
		
		get("1.1/statuses/show.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
			
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)

		}, failure: { (task: URLSessionDataTask?, error: Error) in

			failure(error)
			
		})
	}
	
	
	
	// Get user's mentions timeline
	//	GET https://api.twitter.com/1.1/statuses/mentions_timeline.json?count=2&since_id=14927799
	func mentionsTimeline(maxID: Int?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
		
		var params: [String: Any]?
		if let max = maxID {
			params = ["max_id": "\(max)", "include_entities": "true"]
			
		}
		get("1.1/statuses/mentions_timeline.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
			
			print("timeline: \(response)")
			let dicts = response as! [[String: Any?]]
			let tweets = Tweet.tweetsWithArray(dicts: dicts)
			success(tweets)
			
		}, failure: { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		})
	}
	
	
	
	// Get user's user timeline
	//	GET https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=twitterapi&count=2
	func userTimeline(screenName: String?, maxID: Int?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
		
		var params: [String: Any] = ["include_entities": "true"]
		if let max = maxID {
			params["max_id"] = "\(max)"
		}
		
		if let sn = screenName {
			params["screen_name"] = sn
		}

		get("1.1/statuses/user_timeline.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
			
			print("timeline: \(response)")
			let dicts = response as! [[String: Any?]]
			let tweets = Tweet.tweetsWithArray(dicts: dicts)
			success(tweets)
			
		}, failure: { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		})
	}
	
	// Get info for a specified user
	//	GET https://api.twitter.com/1.1/users/show.json?screen_name=twitterdev
	func getUserInfo(screenName: String, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
		
		let params: [String: Any] = ["screen_name": screenName]
		
		get("1.1/users/show.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
			let userDict = response as! [String: Any?]
			let user = User(dictionary: userDict)
			success(user)
			
		}, failure: { (task: URLSessionDataTask?, error: Error) in
			failure(error)
		})
	}

	
	
	
	
	
	

}
