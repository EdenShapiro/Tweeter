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
//			replyButton 
//			replyCountLabel =
			if tweet.retweeted {
				setRetweetButtonActivated()
			} else {
				setRetweetButtonDeactivated()
			}
			retweetCountLabel.text = "\(tweet.retweetCount)"
			if tweet.favorited {
				setFavoriteButtonActivated()
			} else {
				setFavoriteButtonDeactivated()
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
			setFavoriteButtonDeactivated()
			//-send favorite post request deleting favorite
			//decrement favorite count
		} else {
			setFavoriteButtonActivated()
			//-send favorite post request
			//-increment favoritecount
		}
		
	}
	
	@IBAction func retweetButtonClicked(_ sender: Any) {
		//create alertview asking:
		//-retweet
		//-quote tweet
		// cancel
		//
		//if retweet:
		//-send retweet post request
		//-turn retweet button and retweetcountlabel green
		//if cancel:
		//do nothing
		
	}

	func setFavoriteButtonActivated(){
		favoriteButton.isSelected = true
		let origImage = UIImage(named: "favorite")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		favoriteButton.setImage(tintedImage, for: .selected)
		favoriteButton.tintColor = .red
		favoriteCountLabel.textColor = .red
	}
	
	func setFavoriteButtonDeactivated(){
		favoriteButton.isSelected = false
		let origImage = UIImage(named: "favorite")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		favoriteButton.setImage(tintedImage, for: .normal)
		favoriteButton.tintColor = .darkGray
		favoriteCountLabel.textColor = .darkGray

	}
	
	func setRetweetButtonActivated(){
		let origImage = UIImage(named: "retweet")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		retweetButton.setImage(tintedImage, for: .selected)
		retweetButton.tintColor = .green
		retweetCountLabel.textColor = .green
	}
	
	func setRetweetButtonDeactivated(){
		let origImage = UIImage(named: "retweet")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		retweetButton.setImage(tintedImage, for: .normal)
		retweetButton.tintColor = .darkGray
		retweetCountLabel.textColor = .darkGray
	}
	

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
