//
//  TweetsTableVC.swift
//  Twitter
//
//  Created by Eden on 9/25/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import KRProgressHUD

class TweetsTableVC: UIViewController, TweetCellDelegate {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var birdImage: UIImageView!
	@IBOutlet weak var newTweetButton: UIBarButtonItem!
	@IBOutlet weak var logoutButton: UIBarButtonItem!
	
	var tweets: [Tweet] = [Tweet]()
	var replyTweetData: (Int, String)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 120
		tableView.rowHeight = UITableViewAutomaticDimension
		
		TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) in
			self.tweets = tweets
			self.tableView.reloadData()	
		}, failure: { (error: Error) in
			print("Could not find tweets: \(error.localizedDescription)")
		})
		birdImage.changeToColor(color: UIColor.TwitterColors.Blue)
		
		logoutButton.tintColor = UIColor.TwitterColors.Blue
		newTweetButton.tintColor = UIColor.TwitterColors.Blue
		
		self.navigationController?.navigationBar.barTintColor = .white
		self.navigationController?.navigationBar.backgroundColor = .white
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
		tableView.insertSubview(refreshControl, at: 0)

		
	}
	func updateTweetInfo(indexPath: IndexPath, tweet: Tweet){
		tweets[indexPath.row] = tweet
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
	
	func createReplyTweet(tweetId: Int, screenName: String){
		self.replyTweetData = (tweetId, screenName)
		self.performSegue(withIdentifier: "NewTweetVCSegue", sender: self)
	}
	
	func presentAlertViewController(alertController: UIAlertController){
		self.present(alertController, animated: true)
		
	}
	
	@IBAction func logoutButtonClicked(_ sender: Any) {
		TwitterClient.sharedInstance.logout()
	}
	
	
	@IBAction func didPostNewTweet(segue: UIStoryboardSegue) {
		if let newTweetVC = segue.source as? NewTweetVC {
			if let newestTweet = newTweetVC.finalTweet {
				tweets.insert(newestTweet, at: 0)
				tableView.reloadData()
			}
		}
	}
	
	@IBAction func didCancelNewTweet(segue: UIStoryboardSegue) {
		print("TWEET CANCELLED")
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		print("in prep for segue")
		if segue.identifier == "TweetDetailVCSegue"{
			let tweetDetailsVC = segue.destination as! TweetDetailVC
			tweetDetailsVC.delegate = self
			if let cell = sender as? TweetCell, let indexPath = tableView.indexPath(for: cell) {
				tweetDetailsVC.indexPath = indexPath
				tweetDetailsVC.tweet = tweets[indexPath.row]
			}
		}
		if segue.identifier == "NewTweetVCSegue" {
			let newTweetVC = segue.destination as! NewTweetVC
			newTweetVC.replyTweetId = replyTweetData?.0
			newTweetVC.replyTweetScreenName = replyTweetData?.1
	
		}
	}
	
	
	func refreshControlAction(_ refreshControl: UIRefreshControl) {
		TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) in
			self.tweets = tweets
			self.tableView.reloadData()
			refreshControl.endRefreshing()
		}, failure: {(e: Error) in
			print("There was an error: \(e.localizedDescription)")
//			self.networkErrorLabel.isHidden = false
			KRProgressHUD.set(font: .systemFont(ofSize: 15))
			KRProgressHUD.showError(withMessage: "Unable to load movies.")
			refreshControl.endRefreshing()
		
		})
		
	}


}

extension TweetsTableVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated:true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
		cell.delegate = self
		if let retweetStatus = tweets[indexPath.row].retweetStatus {
			cell.retweeterName = tweets[indexPath.row].tweeter!.name
			cell.tweet = retweetStatus
		} else {
			cell.tweet = tweets[indexPath.row]
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return tweets.count
	}
	
}


extension UIColor {
	
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
	convenience init(netHex:Int) {
		self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
	}
	
	struct TwitterColors {
		static let Blue = UIColor(netHex: 0x00ACED)
		static let DarkBlue = UIColor(netHex: 0x0084B4)
		static let VerifiedBlue = UIColor(netHex: 0x1dcaff)
		static let BackgroundBlue = UIColor(netHex: 0xc0deed)
	}
}

extension UIImageView {
	func changeToColor(color: UIColor){
		self.image = self.image!.withRenderingMode(.alwaysTemplate)
		self.tintColor = color
	}
}
