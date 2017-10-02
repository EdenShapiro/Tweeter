//
//  TweetDetailVC.swift
//  Twitter
//
//  Created by Eden on 9/28/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import NSDateMinimalTimeAgo
import AFNetworking


class TweetDetailVC: UIViewController {

	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var screenNameLabel: UILabel!
	@IBOutlet weak var timeStampLabel: UILabel!
	@IBOutlet weak var replyButton: UIButton!
	@IBOutlet weak var retweetButton: UIButton!
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var tweetContentsLabel: UILabel!
	@IBOutlet weak var retweetCountLabel: UILabel!
	@IBOutlet weak var favoriteCountLabel: UILabel!
	@IBOutlet weak var retweetsLabel: UILabel!
	@IBOutlet weak var likesLabel: UILabel!
	@IBOutlet weak var likesLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var mediaImageView: UIImageView!
	
	@IBOutlet weak var mediaImageViewHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var mediaImageViewWidthConstraint: NSLayoutConstraint!
	

	@IBOutlet weak var dateToMediaImageConstraint: NSLayoutConstraint!
	
	
	var tweet: Tweet!
	var indexPath: IndexPath!
	weak var delegate: TweetCellDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupTweetElements()
		updateLikesAndRetweetsElements()
		
		self.navigationController?.navigationBar.tintColor = UIColor.TwitterColors.Blue
    }
	
	
	
	func setupTweetElements(){
		let formatter = DateFormatter()
		formatter.dateFormat = "M/dd/yy, h:mm a"
		timeStampLabel.text = "\(formatter.string(from: tweet.createdAt!))"
		tweetContentsLabel.text = tweet.text
		
		replyButton.setDeactivated(label: nil)
		
		if let user = tweet.tweeter {
			if let url = user.profileURL{
				profilePicImageView.setImageWith(url)
				profilePicImageView.clipsToBounds = true
				profilePicImageView.layer.cornerRadius = 7
			}
			nameLabel.text = user.name
			screenNameLabel.text = "@\(user.screenName!)"
		}
		
		setUpMediaImage(url: tweet.mediaURL)
	}
	
	func setUpMediaImage(url: URL?){
		if let mediaUrl = url {
			mediaImageView.setImageWith(mediaUrl)
			if let img = mediaImageView.image {
				if img.size.width > img.size.height {
					mediaImageViewWidthConstraint.constant = self.view.frame.size.width
				} else if img.size.width < img.size.height {
					mediaImageViewHeightConstraint.constant = 300
				}
			}
			mediaImageView.isHidden = false
			dateToMediaImageConstraint.constant = 8

			mediaImageView.contentMode = .scaleAspectFill
			mediaImageView.clipsToBounds = true
			self.view.updateConstraints()
		} else {
			mediaImageView.image = nil
			mediaImageView.isHidden = true
			dateToMediaImageConstraint.constant = 0
			mediaImageViewHeightConstraint.constant = 0
			self.view.updateConstraints()
			
		}
	}
	
	func updateLikesAndRetweetsElements(){
		if tweet.retweetCount > 0 {
			retweetCountLabel.text = "\(tweet.retweetCount.formatToString())"
			likesLeadingConstraint.constant = 116
			self.updateViewConstraints()
		} else {
			retweetsLabel.isHidden = true
			retweetCountLabel.isHidden = true
			retweetCountLabel.text = ""
			likesLeadingConstraint.constant = 0
			self.updateViewConstraints()
		}
		if tweet.favoritesCount > 0 {
			favoriteCountLabel.text = "\(tweet.favoritesCount.formatToString())"
		} else {
			likesLabel.isHidden = true
			favoriteCountLabel.isHidden = true
			favoriteCountLabel.text = ""
		}
		if tweet.retweeted {
			retweetButton.setActivated(color: .green, label: nil)
		} else {
			retweetButton.setDeactivated(label: nil)
		}
		
		if tweet.favorited {
			favoriteButton.setActivated(color: .red, label: nil)
		} else {
			favoriteButton.setDeactivated(label: nil)
		}
	}

	@IBAction func replyButtonClicked(_ sender: Any) {
		delegate?.createReplyTweet(tweetId: tweet.id!, screenName: (tweet.tweeter?.screenName)!)
	}
	
	@IBAction func retweetButtonClicked(_ sender: Any) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		if retweetButton.isSelected {
			let undoRetweet = UIAlertAction(title: "Undo Retweet", style: .default) { action in
				TwitterClient.sharedInstance.unretweet(tweetID: self.tweet.id!, success: { (originalTweet: Tweet) in
					TwitterClient.sharedInstance.unretweet(tweetID: originalTweet.id!, success: { (originalTweet: Tweet) in
						self.tweet = originalTweet
						self.updateLikesAndRetweetsElements()
						self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: originalTweet)
						print("originalTweet.retweeted: \(originalTweet.retweeted)")
						print("likes: \(originalTweet.favoritesCount)")
					}, failure: { (e: Error) in
						print("Error: \(e.localizedDescription)")
					})

					
				}, failure: { (e: Error) in
					print("Error: \(e.localizedDescription)")
				})
			}
			alertController.addAction(undoRetweet)
		} else {
			let retweet = UIAlertAction(title: "Retweet", style: .default) { action in
				TwitterClient.sharedInstance.retweet(tweetID: self.tweet.id!, success: { (originalTweet: Tweet) in
					self.tweet = originalTweet
					print("originalTweet.retweeted: \(originalTweet.retweeted)")
					print("likes: \(originalTweet.favoritesCount)")
					self.updateLikesAndRetweetsElements()
					self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: originalTweet)
				}, failure: { (e: Error) in
					print("Error: \(e.localizedDescription)")
				})
			}
			alertController.addAction(retweet)
		}
		self.present(alertController, animated: true)
	}
	
	@IBAction func favoriteButtonClicked(_ sender: Any) {
		
		if favoriteButton.isSelected {
			TwitterClient.sharedInstance.unfavorite(tweetID: self.tweet.id!, success: { (originalTweet:Tweet) in
				self.tweet = originalTweet
				self.updateLikesAndRetweetsElements()
				self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: originalTweet)
			}, failure: { (e: Error) in
				print("Error: \(e.localizedDescription)")
			})
		} else {
			TwitterClient.sharedInstance.favorite(tweetID: self.tweet.id!, success: { (originalTweet: Tweet) in
				self.tweet = originalTweet
				self.updateLikesAndRetweetsElements()
				self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: originalTweet)
			}, failure: { (e: Error) in
				print("Error: \(e.localizedDescription)")
			})
		}
	}
	
	


}
