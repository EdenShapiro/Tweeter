//
//  TwitterClient.swift
//  Twitter
//
//  Created by Eden on 9/26/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

//153220282-YUkj24RJfmwFmbQn5nMfbMnHqq9pqnqO60bPYux7

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
	func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
		
		get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
			
			print("timeline: \(response)")
			let dicts = response as! [[String: Any?]]
			let tweets = Tweet.tweetsWithArray(dicts: dicts)
			success(tweets)
//			for tweet in tweets {
//				print(tweet.text ?? "no tweets")
//			}
			
		}, failure: { (task: URLSessionDataTask?, error: Error) in
//			print("Error getting home timeline: \(error.localizedDescription)")
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
	// NOTE: this may not work because it's not
//	POST https://api.twitter.com/1.1/statuses/retweet/243149503589400576.json
//response:
//	"retweeted": false,
//	"retweet_count": 1,

	func retweet(tweetID: Int, success: @escaping (Tweet) -> (), failure:
		@escaping (Error) -> ()) {
		
		let params: [String: Any] = ["id": "\(tweetID)"]
		
		post("1.1/statuses/retweet.json", parameters: params, progress: nil, success: {
			(task: URLSessionDataTask, response: Any?) in
//			let response = response as! [String: Any?]
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)
			//send back true and retweet count
//			let wasRetweeted = response["retweeted"] as! Bool
//			let retweetCount = response["retweet_count"] as! Int
//			success((wasRetweeted, retweetCount))
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
//			let response = response as! [String: Any?]
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)
			//send back true and retweet count
//			let wasUnretweeted = response["retweeted"] as! Bool
//			let retweetCount = response["retweet_count"] as! Int
//			success((wasUnretweeted, retweetCount))
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
//			let response = response as! [String: Any?]
			let tweet = Tweet(dict: response as! [String: Any?])
			success(tweet)
			//send back true and favorites count
//			let wasFavorited = response["favorited"] as! Bool
//			let favoritesCount = response["favourites_count"] as! Int
//			success((wasFavorited, favoritesCount))
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
//			let response = response as! [String: Any?]
//
//			//send back true and favorites count
//			let wasUnfavorited = response["favorited"] as! Bool
//			let favoritesCount = response["favourites_count"] as! Int
//			success((wasUnfavorited, favoritesCount))
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
	
	
	
}
