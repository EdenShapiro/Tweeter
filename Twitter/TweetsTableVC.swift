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
	
	var loadingMoreView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
	var tweets: [Tweet] = [Tweet]()
	var replyTweetData: (Int, String)?
	var isMoreDataLoading = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 120
		tableView.rowHeight = UITableViewAutomaticDimension
		
		// Fetch timeline tweets
		TwitterClient.sharedInstance.homeTimeline(maxID: nil, success: { (tweets: [Tweet]) in
			self.tweets = tweets
			self.tableView.reloadData()
			KRProgressHUD.showSuccess()
		}, failure: { (error: Error) in
			print("Could not find tweets: \(error.localizedDescription)")
		})
		
		// UI setup
		setUpUI()
		
		// Heads Up Display
		triggerHUD()
		
		// Refresh Control
		setUpRefreshControl()
		
		// Infinite scrolling
		setUpInfiniteScrolling()
	}
	
//================================================== Helper Methods =====================================================
	
	func setUpUI(){
		birdImage.changeToColor(color: UIColor.TwitterColors.Blue)
		
		logoutButton.tintColor = UIColor.TwitterColors.Blue
		newTweetButton.tintColor = UIColor.TwitterColors.Blue
		
		self.navigationController?.navigationBar.barTintColor = .white
		self.navigationController?.navigationBar.backgroundColor = .white
	}
	
	func triggerHUD(){
		KRProgressHUD.set(style: .white)
		KRProgressHUD.set(font: .systemFont(ofSize: 15))
		KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: UIColor.TwitterColors.Blue, tail: UIColor.TwitterColors.DarkBlue))
		KRProgressHUD.show(withMessage: "Loading tweets...")
	}
	
	func setUpInfiniteScrolling(){
		let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
		loadingMoreView.center = tableFooterView.center
		tableFooterView.insertSubview(loadingMoreView, at: 0)
		self.tableView.tableFooterView = tableFooterView
	}
	
	func setUpRefreshControl(){
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
		tableView.insertSubview(refreshControl, at: 0)
	}
	
	func refreshControlAction(_ refreshControl: UIRefreshControl) {
		TwitterClient.sharedInstance.homeTimeline(maxID: nil, success: { (tweets: [Tweet]) in
			self.tweets = tweets
			self.tableView.reloadData()
			refreshControl.endRefreshing()
		}, failure: {(e: Error) in
			print("There was an error: \(e.localizedDescription)")
			KRProgressHUD.set(font: .systemFont(ofSize: 15))
			KRProgressHUD.showError(withMessage: "Unable to load tweets.")
			refreshControl.endRefreshing()
			
		})
		
	}
	
//================================================== Delegate Methods =====================================================

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
	
	func reloadCell(cell: TweetCell, tweet: Tweet, success: @escaping () -> (), failure: @escaping () -> ()) {
		print("reload cell called")
		if let indexPath = tableView.indexPath(for: cell) {
			tweets[indexPath.row] = tweet
			tableView.reloadRows(at: [indexPath], with: .automatic)
			success()
		} else {
			failure()
		}
	}
	
	func reloadCell(cell: TweetCell, tweet: Tweet){
		
	}
	
	
	@IBAction func logoutButtonClicked(_ sender: Any) {
		TwitterClient.sharedInstance.logout()
	}
	
//================================================== Segue Methods =====================================================
	
	@IBAction func didPostNewTweet(segue: UIStoryboardSegue) {
		if let newTweetVC = segue.source as? NewTweetVC {
			if let newestTweet = newTweetVC.finalTweet {
				print("did post new tweet called")
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
}


//================================================== TweetsTableVC Extensions =====================================================


extension TweetsTableVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated:true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
		cell.delegate = self
		cell.retweeterName = nil
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



extension TweetsTableVC: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if (!isMoreDataLoading) {
			// Calculate the position of one screen length before the bottom of the results
			let scrollViewContentHeight = tableView.contentSize.height
			let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
			
			// When the user has scrolled past the threshold, start requesting
			if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
				isMoreDataLoading = true
				self.loadingMoreView.startAnimating()
				loadMoreData()
			}
		}
	}
	
	func loadMoreData() {
		TwitterClient.sharedInstance.homeTimeline(maxID: tweets[tweets.count - 1].id!, success: { (tweets: [Tweet]) in
			self.isMoreDataLoading = false
			self.tweets.append(contentsOf: tweets.dropFirst())
			self.tableView.reloadData()
			self.loadingMoreView.stopAnimating()
		}, failure: { (error: Error) in
			print("Could not find tweets: \(error.localizedDescription)")
			KRProgressHUD.set(font: .systemFont(ofSize: 15))
			KRProgressHUD.showError(withMessage: "Unable to load tweets.")
			self.isMoreDataLoading = false
			self.loadingMoreView.stopAnimating()
		})
	}
}


//================================================== Unrelated Extensions ======================================================

extension UIButton {
	func setActivated(color: UIColor, label: UILabel?){
		self.isSelected = true
		let orginalImage = self.imageView?.image
		let newColorImage = orginalImage?.withRenderingMode(.alwaysTemplate)
		self.setImage(newColorImage, for: .selected)
		self.tintColor = color
		if let lab = label {
			lab.textColor = color
		}
	}
	
	func setDeactivated(label: UILabel?){
		self.isSelected = false
		let orginalImage = self.imageView?.image
		let newColorImage = orginalImage?.withRenderingMode(.alwaysTemplate)
		self.setImage(newColorImage, for: .normal)
		self.tintColor = .darkGray
		if let lab = label {
			lab.textColor = .darkGray
		}
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



//extension TweetsTableVC: TweetDetailDelegate {
//
//
//}
