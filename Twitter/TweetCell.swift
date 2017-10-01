//
//  TweetCell.swift
//  Twitter
//
//  Created by Eden on 9/28/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import AFNetworking
import NSDateMinimalTimeAgo

@objc protocol TweetCellDelegate {
	func createReplyTweet(tweetId: Int, screenName: String)
	func updateTweetInfo(indexPath: IndexPath, tweet: Tweet)
	func presentAlertViewController(alertController: UIAlertController)
	func reloadCell(cell: TweetCell, tweet: Tweet, success: @escaping () -> (), failure: @escaping () -> ())
}

class TweetCell: UITableViewCell {
	
	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var screenNameLabel: UILabel!
	@IBOutlet weak var timeStampLabel: UILabel!
	@IBOutlet weak var tweetContentsLabel: UILabel!
	@IBOutlet weak var replyButton: UIButton!
	@IBOutlet weak var replyCountLabel: UILabel!
	@IBOutlet weak var retweetButton: UIButton!
	@IBOutlet weak var retweetCountLabel: UILabel!
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var favoriteCountLabel: UILabel!
	@IBOutlet weak var retweetSmallImageView: UIImageView!
	@IBOutlet weak var retweetedByNameLabel: UILabel!
	
	@IBOutlet weak var profPicimageViewTopConstraint: NSLayoutConstraint!
	
	var retweeterName: String?
	weak var delegate: TweetCellDelegate?
	
	
	var tweet: Tweet! {
		didSet {
			let formatter = DateFormatter()
			formatter.dateFormat = "M/dd/yy"
			let charset = CharacterSet(charactersIn: "dwy")
			if let date = tweet.createdAt {
				let nsDate = date as NSDate
				if nsDate.timeAgo().contains("mo") || nsDate.timeAgo().rangeOfCharacter(from: charset) != nil {
					timeStampLabel.text = "∙ \(formatter.string(from: tweet.createdAt!))"
				} else {
					timeStampLabel.text = "∙ \(nsDate.timeAgo()!)"
				}
			}
			tweetContentsLabel.text = tweet.text
			if tweet.replyCount > 0 {
				replyCountLabel.text = "\(tweet.replyCount)"
			}
			if tweet.retweetCount > 0 {
				retweetCountLabel.text = "\(tweet.retweetCount)"
			}
			if tweet.favoritesCount > 0 {
				favoriteCountLabel.text = "\(tweet.favoritesCount)"
			}
			
			replyButton.setDeactivated(label: nil)
			if tweet.retweeted {
				retweetButton.setActivated(color: .green, label: retweetCountLabel)
			} else {
				retweetButton.setDeactivated(label: retweetCountLabel)
			}

			if tweet.favorited {
				favoriteButton.setActivated(color: .red, label: favoriteCountLabel)
			} else {
				favoriteButton.setDeactivated(label: favoriteCountLabel)
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
			
			updateCellToShowRetweetStatus()
			
		}

	}
	
	func updateCellToShowRetweetStatus(){
		if let retweetName = retweeterName {
			profPicimageViewTopConstraint.constant = 20
			retweetSmallImageView.changeToColor(color: .darkGray)
			retweetSmallImageView.isHidden = false
			retweetedByNameLabel.text = "\(retweetName) Retweeted"
			retweetedByNameLabel.isHidden = false
			self.updateConstraints()

		} else {
			profPicimageViewTopConstraint.constant = 0
			retweetedByNameLabel.isHidden = true
			retweetSmallImageView.isHidden = true
			self.updateConstraints()
		}
//		self.delegate?.reloadCell(cell: self, tweet: self.tweet)
//		self.delegate?.updateTweetInfo(indexPath: self.indexPath, tweet: self.tweet)
	}

	@IBAction func favoriteButtonClicked(_ sender: Any) {
		if favoriteButton.isSelected {
			favoriteButton.setDeactivated(label: favoriteCountLabel)
			TwitterClient.sharedInstance.unfavorite(tweetID: tweet.id!, success: { (tweet: Tweet) in
				self.tweet = tweet
			}, failure: { (e: Error) in
				print("Error: \(e.localizedDescription)")
			})
		} else {
			favoriteButton.setActivated(color: .red, label: favoriteCountLabel)
			TwitterClient.sharedInstance.favorite(tweetID: tweet.id!, success: { (tweet: Tweet) in
				self.tweet = tweet
			}, failure: { (e: Error) in
				print("Error: \(e.localizedDescription)")
			})
		}
		
	}
	
	@IBAction func replyButtonClicked(_ sender: Any) {
		delegate?.createReplyTweet(tweetId: tweet.id!, screenName: (tweet.tweeter?.screenName)!)		
	}
	
	
	@IBAction func retweetButtonClicked(_ sender: Any) {
		//create alertview
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		if retweetButton.isSelected {
			let undoRetweet = UIAlertAction(title: "Undo Retweet", style: .default) { action in
				TwitterClient.sharedInstance.unretweet(tweetID: self.tweet.id!, success: { (originalTweet: Tweet) in
					TwitterClient.sharedInstance.unretweet(tweetID: originalTweet.id!, success: { (originalTweet: Tweet) in
						self.retweeterName = nil
						self.delegate?.reloadCell(cell: self, tweet: originalTweet, success: { () in
							self.retweetButton.setDeactivated(label: self.retweetCountLabel)
							
						}, failure: { () in
							print("Error: Did not reload cell")
						})
						//					self.delegate?.reloadCell(cell: self, tweet: originalTweet)
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
					self.retweeterName = User.currentUser?.name
					self.delegate?.reloadCell(cell: self, tweet: originalTweet, success: { () in
						print("We're good.")
					}, failure: { () in
						print("Error: Did not reload cell")
					})
//						self.retweetButton.setDeactivated(label: self.retweetCountLabel)
//					self.updateCellToShowRetweetStatus()
//					self.retweetCountLabel.text = "\(self.tweet.retweetCount + 1)"
//					self.retweetButton.setActivated(color: .green, label: self.retweetCountLabel)
					
				}, failure: { (e: Error) in
					print("Error: \(e.localizedDescription)")
				})
			}
			alertController.addAction(retweet)
		}
		self.delegate?.presentAlertViewController(alertController: alertController)

		
		
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


//					




//					TwitterClient.sharedInstance.getTweetWithId(tweetID: originalTweet.id!, success: { (tweet: Tweet) in
//						self.retweeterName = nil
//						if let retweetStatus = tweet.retweetStatus{
//							self.retweeterName = tweet.tweeter!.name
//							self.tweet = retweetStatus
//							self.profPicimageViewTopConstraint.constant = 0
//
//						} else {
//
//							self.tweet = tweet
//
//						}
//
//					}, failure: { (e: Error) in
//						print("Problem fetching tweet with ID: \(e.localizedDescription)")
//					})

