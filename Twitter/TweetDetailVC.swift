//
//  TweetDetailVC.swift
//  Twitter
//
//  Created by Eden on 9/28/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import NSDateMinimalTimeAgo

//@objc protocol TweetDetailDelegate {
//	func updateTweetInfo(indexPath: IndexPath, tweet: Tweet)
//}

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
	
	
	var tweet: Tweet!
	var indexPath: IndexPath!
	weak var delegate: TweetCellDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupLabelsAndButtons()

    }
	
	
	
	func setupLabelsAndButtons(){
		let formatter = DateFormatter()
		formatter.dateFormat = "M/dd/yy, h:mm a"
		timeStampLabel.text = "\(formatter.string(from: tweet.createdAt!))"
		tweetContentsLabel.text = tweet.text
		if tweet.retweetCount > 0 {
			retweetCountLabel.text = "\(tweet.retweetCount)"
		} else {
			retweetsLabel.isHidden = true
			retweetCountLabel.isHidden = true
		}
		if tweet.favoritesCount > 0 {
			favoriteCountLabel.text = "\(tweet.favoritesCount)"
		} else {
			likesLabel.isHidden = true
			favoriteCountLabel.isHidden = true
		}
		replyButton.setDeactivated(label: nil)
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
		
		if let user = tweet.tweeter {
			if let url = user.profileURL{
				profilePicImageView.setImageWith(url)
				profilePicImageView.clipsToBounds = true
				profilePicImageView.layer.cornerRadius = 7
			}
			nameLabel.text = user.name
			screenNameLabel.text = "@\(user.screenName!)"
			
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
//					self.tweet = originalTweet
//					self.setupLabelsAndButtons()
					self.retweetButton.setDeactivated(label: nil)
					self.retweetCountLabel.text = "\(self.tweet.retweetCount - 1)"
					self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: originalTweet)
				}, failure: { (e: Error) in
					print("Error: \(e.localizedDescription)")
				})
			}
			alertController.addAction(undoRetweet)
		} else {
			
			let retweet = UIAlertAction(title: "Retweet", style: .default) { action in
				TwitterClient.sharedInstance.retweet(tweetID: self.tweet.id!, success: { (originalTweet: Tweet) in
//					self.tweet = originalTweet
					print("originalTweet.retweeted: \(originalTweet.retweeted)")
//					self.setupLabelsAndButtons()
					self.retweetButton.setActivated(color: .green, label: nil)
					self.retweetCountLabel.text = "\(self.tweet.retweetCount + 1)"
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
			favoriteButton.setDeactivated(label: nil)
			TwitterClient.sharedInstance.unfavorite(tweetID: self.tweet.id!, success: { (tweet:Tweet) in
				self.tweet = tweet
				self.setupLabelsAndButtons()
				self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: self.tweet)
			}, failure: { (e: Error) in
				print("Error: \(e.localizedDescription)")
			})
			//-send favorite post request deleting favorite
			//decrement favorite count
		} else {
			TwitterClient.sharedInstance.favorite(tweetID: self.tweet.id!, success: { (tweet: Tweet) in
				self.tweet = tweet
				self.setupLabelsAndButtons()
				self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: self.tweet)
			}, failure: { (e: Error) in
				print("Error: \(e.localizedDescription)")
			})
			favoriteButton.setActivated(color: .red, label: nil)

			//-send favorite post request
			//-increment favoritecount
		}

	}
	
	


}
