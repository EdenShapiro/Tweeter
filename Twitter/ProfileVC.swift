//
//  ProfileVC.swift
//  Twitter
//
//  Created by Eden on 10/6/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import KRProgressHUD
import AFNetworking
import FXBlurView

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the bottom of the Header and the top of the White Label


class ProfileVC: UIViewController, TweetCellDelegate {
	
	//	class TweetsTableVC: UIViewController, TweetCellDelegate {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var newTweetButton: UIBarButtonItem!
	@IBOutlet weak var profileBackgroundImageView: UIImageView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var profileName: UILabel!
	@IBOutlet weak var profileScreenName: UILabel!
	@IBOutlet weak var profileExtraButton: UIButton!
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var headerBlurImageView: UIImageView!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var tweetsSegmentedControl: UISegmentedControl!
	@IBOutlet weak var followingCountLabel: UILabel!
	@IBOutlet weak var followersCountLabel: UILabel!
	
	@IBOutlet weak var tableHeaderView: UIView!
	
	var user: User!
	
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
		tableView.tableHeaderView = tableHeaderView
		// Fetch user timeline tweets
		TwitterClient.sharedInstance.userTimeline(screenName: user.screenName!, maxID: nil, success: { (tweets: [Tweet]) in
			self.tweets = tweets
			self.tableView.reloadData()
			KRProgressHUD.showSuccess()
		}, failure: { (error: Error) in
			print("Could not find profile: \(error.localizedDescription)")
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
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
//		guard let header = tableView.tableHeaderView else {
//			print("there is no tableHeaderView")
//			return
//		}
		let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
		if headerView.frame.size.height != size.height {
			headerView.frame.size.height = size.height
			tableView.tableHeaderView = headerView
			tableView.layoutIfNeeded()
		}
	}
	
	//================================================== Helper Methods =====================================================
	
	
	func setUpUI(){
		
		// Set up background image
		if let bgImageURL = user.backgroundImageURL {
			profileBackgroundImageView.setImageWith(bgImageURL)
			headerBlurImageView.setImageWith(bgImageURL)
		} else {
			profileBackgroundImageView.image = UIImage(color: UIColor.TwitterColors.Blue)
			headerBlurImageView.image = UIImage(color: UIColor.TwitterColors.Blue)
		}
		
		let tempImage = headerBlurImageView?.image
		headerBlurImageView?.image = tempImage?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
		headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
		headerBlurImageView?.alpha = 0.0
		headerView.clipsToBounds = true
		tableView.clipsToBounds = true

		if let profURL = user.profileURL {
			profileImageView.setImageWith(profURL)
			profileImageView.layer.borderColor = UIColor.white.cgColor
			profileImageView.layer.borderWidth = 3.0
			profileImageView.layer.cornerRadius = 7
			profileImageView.clipsToBounds = true

		}
		
		if let followersCount = user.followersCount{
			followersCountLabel.text = "\(followersCount.formatToString())"
		}
		
		if let followingCount = user.followingCount{
			followingCountLabel.text = "\(followingCount.formatToString())"
		}
		
		if let tweetCount = user.tweetCount {
			tweetsSegmentedControl.setTitle("\(tweetCount.formatToString()) Tweets", forSegmentAt: 0)
		} else {
			tweetsSegmentedControl.setTitle("Tweets", forSegmentAt: 0)
		}
		
		if let likesCount = user.favoritesCount {
			tweetsSegmentedControl.setTitle("\(likesCount.formatToString()) Likes", forSegmentAt: 1)
		} else {
			tweetsSegmentedControl.setTitle("Likes", forSegmentAt: 1)
		}
		
		profileName.text = user.name
		profileScreenName.text = "@\(user.screenName!)"
		if user == User.currentUser {
			profileExtraButton.titleLabel?.text = "Accounts"
			//insert action
		} else {
			profileExtraButton.titleLabel?.text = "Follow"
			//insert follow action
		}
		
		profileExtraButton.layer.cornerRadius = 7
		profileExtraButton.layer.borderWidth = 0.8
		profileExtraButton.layer.borderColor = UIColor.TwitterColors.Blue.cgColor
		
		
		headerLabel.text = user.name
		if let descrip = user.profileDescription {
			descriptionLabel.text = descrip
		}
		
		newTweetButton.tintColor = .white
		
		let items = self.navigationController?.navigationBar.items
		
		self.presentingViewController?.navigationItem.backBarButtonItem?.title = ""
		self.presentingViewController?.navigationController?.navigationItem.backBarButtonItem?.title = ""
		self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = ""
		self.navigationController?.navigationBar.backItem?.leftBarButtonItem?.title = ""
		self.navigationController?.navigationItem.backBarButtonItem?.title = ""
		self.navigationItem.backBarButtonItem?.title = ""
		
		
		
		self.navigationItem.backBarButtonItem?.tintColor = .white


		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.barTintColor = .clear
		self.navigationController?.navigationBar.backgroundColor = .clear
		self.navigationController?.navigationBar.isTranslucent = true
		
		self.view.layoutSubviews()
	}
	
//	override func layout
	
	func triggerHUD(){
		KRProgressHUD.set(style: .white)
		KRProgressHUD.set(font: .systemFont(ofSize: 15))
		KRProgressHUD.set(activityIndicatorViewStyle: .gradationColor(head: UIColor.TwitterColors.Blue, tail: UIColor.TwitterColors.DarkBlue))
		KRProgressHUD.show(withMessage: "Loading profile...")
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
		TwitterClient.sharedInstance.userTimeline(screenName: user.screenName!, maxID: nil, success: { (tweets: [Tweet]) in
			self.tweets = tweets
			self.tableView.reloadData()
			refreshControl.endRefreshing()
		}, failure: {(e: Error) in
			print("There was an error: \(e.localizedDescription)")
			KRProgressHUD.set(font: .systemFont(ofSize: 15))
			KRProgressHUD.showError(withMessage: "Unable to load profile.")
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
	
	func segueToUserProfile(screenName: String) {
		TwitterClient.sharedInstance.getUserInfo(screenName: screenName, success: { (user: User) in
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let profVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
			profVC.user = user
			self.navigationController?.pushViewController(profVC, animated: true)
		}, failure: { (e: Error) in
			print("There was an error in handleProfPicTap: \(e.localizedDescription)")
		})
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


extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
	
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
	
	
	
extension ProfileVC: UIScrollViewDelegate {
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
		
		let offset = scrollView.contentOffset.y
		var avatarTransform = CATransform3DIdentity
		var headerTransform = CATransform3DIdentity
		
		// PULL DOWN -----------------
		
		if offset < 0 {
			
			let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
			let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2.0
			headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
			headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
			
			headerView.layer.transform = headerTransform
		}
			
			// SCROLL UP/DOWN ------------
			
		else {
			
			// Header -----------
			
			headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
			
			//  ------------ Label
			
			let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
			headerLabel.layer.transform = labelTransform
			
			//  ------------ Blur
			
			headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
			
			// Avatar -----------
			
			let avatarScaleFactor = (min(offset_HeaderStop, offset)) / profileImageView.bounds.height / 1.4 // Slow down the animation
			let avatarSizeVariation = ((profileImageView.bounds.height * (1.0 + avatarScaleFactor)) - profileImageView.bounds.height) / 2.0
			avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
			avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
			
			if offset <= offset_HeaderStop {
				
				if profileImageView.layer.zPosition < headerView.layer.zPosition{
					headerView.layer.zPosition = 0
				}
				
			}else {
				if profileImageView.layer.zPosition >= headerView.layer.zPosition{
					headerView.layer.zPosition = 2
				}
			}
		}
		
		// Apply Transformations
		
		headerView.layer.transform = headerTransform
		profileImageView.layer.transform = avatarTransform
	}
	
	func loadMoreData() {
		TwitterClient.sharedInstance.userTimeline(screenName: user.screenName!, maxID: tweets[tweets.count - 1].id!, success: { (tweets: [Tweet]) in
			self.isMoreDataLoading = false
			self.tweets.append(contentsOf: tweets.dropFirst())
			self.tableView.reloadData()
			self.loadingMoreView.stopAnimating()
		}, failure: { (error: Error) in
			print("Could not find profile: \(error.localizedDescription)")
			KRProgressHUD.set(font: .systemFont(ofSize: 15))
			KRProgressHUD.showError(withMessage: "Unable to load profile.")
			self.isMoreDataLoading = false
			self.loadingMoreView.stopAnimating()
		})
	}
}


