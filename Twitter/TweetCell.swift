//
//  TweetCell.swift
//  Twitter
//
//  Created by Eden on 9/28/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import AFNetworking

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
	
	var tweet: Tweet! {
		didSet {
			timeStampLabel.text = "∙ \(tweet.createdAt!)"

			tweetContentsLabel.text = tweet.text
			setButtonToDeactivated(button: replyButton, name: "reply")
			replyCountLabel.text = "\(tweet.replyCount)"
			if tweet.retweeted {
				setButtonToActivated(button: retweetButton, name: "retweet")
			} else {
				setButtonToDeactivated(button: retweetButton, name: "retweet")
			}
			retweetCountLabel.text = "\(tweet.retweetCount)"
			if tweet.favorited {
				setButtonToActivated(button: favoriteButton, name: "favorite")
			} else {
				setButtonToDeactivated(button: favoriteButton, name: "favorite")
			}
			favoriteCountLabel.text = "\(tweet.favoritesCount)"
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

	}

	@IBAction func favoriteButtonClicked(_ sender: Any) {
		if favoriteButton.isSelected {
			setButtonToDeactivated(button: favoriteButton, name: "favorite")
			//-send favorite post request deleting favorite
			//decrement favorite count
		} else {
			setButtonToActivated(button: favoriteButton, name: "favorite")
			//-send favorite post request
			//-increment favoritecount
		}
		
	}
	
	@IBAction func retweetButtonClicked(_ sender: Any) {
		if retweetButton.isSelected {
			//prompt to undo retweet
			//if yes: setButtonToDeactivated(button: retweetButton, name: "retweet")
		} else {
			//create alertview asking:
			//-retweet
			//-quote tweet
			// cancel
			//
			//if retweet:
			//-send retweet post request
			//setButtonToActivated(button: retweetButton, name: "retweet")
			//if cancel:
			//do nothing
		}
		
		
	}

	
	func setButtonToActivated(button: UIButton, name: String){
		button.isSelected = true
		let orginalImage = button.imageView?.image
		let newColorImage = orginalImage?.withRenderingMode(.alwaysTemplate)
		button.setImage(newColorImage, for: .selected)
		if name == "favorite" {
			favoriteButton.tintColor = .red
			favoriteCountLabel.textColor = .red
		} else if name == "retweet" {
			retweetButton.tintColor = .green
			retweetCountLabel.textColor = .green
		}
	}
	
	func setButtonToDeactivated(button: UIButton, name: String){
		button.isSelected = false
		let orginalImage = button.imageView?.image
		let newColorImage = orginalImage?.withRenderingMode(.alwaysTemplate)
		button.setImage(newColorImage, for: .normal)
		button.tintColor = .darkGray
		if name == "favorite" {
			favoriteCountLabel.textColor = .darkGray
		} else if name == "retweet" {
			retweetCountLabel.textColor = .darkGray
		}
	}
	
	

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
