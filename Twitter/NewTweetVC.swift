//
//  NewTweetVC.swift
//  Twitter
//
//  Created by Eden on 9/27/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class NewTweetVC: UIViewController {
	@IBOutlet weak var profilePictureImageView: UIImageView!

	@IBOutlet weak var cancelTweetButton: UIButton!
	
	@IBOutlet weak var tweetTextView: UITextView!
	
	var postTweetButton: UIBarButtonItem!
//	var postTweetButton: UIButton!
	var characterCountView: UILabel!
	
	var characterCount = 140
	let placeholderText = "What's happening?"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tweetTextView.delegate = self
		
		setUpButtonsAndImageViews()

		setupAccessoryView()
		
		
		
    }
	
	func setUpButtonsAndImageViews(){
		
		tweetTextView.text = placeholderText
		tweetTextView.textColor = UIColor.darkGray
		
		
		let origImage = UIImage(named: "small-x")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		cancelTweetButton.setImage(tintedImage, for: .normal)
		cancelTweetButton.tintColor = UIColor.TwitterColors.Blue
		
		if let user = User.currentUser {
			if let picURL = user.profileURL {
				profilePictureImageView.setImageWith(picURL)
				profilePictureImageView.clipsToBounds = true
				profilePictureImageView.layer.cornerRadius = 7
			}
		}
		
	}
	
	func setupAccessoryView(){
		let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = false
		
		let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		
		postTweetButton = UIBarButtonItem(title: "Tweet", style: .done, target: self, action: #selector(didPressTweetButton))
		
		postTweetButton.tintColor = UIColor.TwitterColors.Blue
		postTweetButton.isEnabled = false

		
		//		postTweetButton = UIButton()
		//		postTweetButton.backgroundColor = UIColor.TwitterColors.BackgroundBlue
		//		postTweetButton.setTitleColor(.white, for: .normal)
		//		postTweetButton.addTarget(self, action: #selector(didPressTweetButton), for: .touchUpInside)
		//		let postTweetButtonItem = UIBarButtonItem(customView: postTweetButton)

		
		characterCountView = UILabel()
		characterCountView.text = "\(characterCount)"
		characterCountView.sizeToFit()
		characterCountView.textColor = .darkGray
		characterCountView.backgroundColor = .clear
		let charCountViewItem = UIBarButtonItem(customView: characterCountView)
		toolBar.items = [flexsibleSpace, charCountViewItem, postTweetButton]
		tweetTextView.inputAccessoryView = toolBar
		
	}

	func didPressTweetButton(){
		print("postTweetButton clicked")
		//post tweet
		self.performSegue(withIdentifier: "didPostNewTweetSegue", sender: self)
	}
	

	
}

extension NewTweetVC: UITextViewDelegate {
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.darkGray {
			textView.text = nil
			textView.textColor = .black
		}
	}
	
	
	func textViewDidChange(_ textView: UITextView) {
//		if textView.text.isEmpty {
//			textView.text = placeholderText
//			textView.textColor = UIColor.darkGray
//			let newPosition = textView.beginningOfDocument
//			textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//		}
		
		characterCount = 140 - textView.text!.characters.count
		if characterCount < 0 || characterCount == 140 {
			postTweetButton.isEnabled = false
		} else {
			postTweetButton.isEnabled = true
		}
		if characterCount < 20 {
			self.characterCountView.textColor = .red
		} else {
			self.characterCountView.textColor = .darkGray
		}
		characterCountView.text = "\(characterCount)"
		characterCountView.sizeToFit()
		textView.reloadInputViews()
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
  
		let newLength = textView.text!.characters.count + text.characters.count - range.length
		if newLength > 0 {
			if textView.text == placeholderText {
				if text.characters.count == 0 {
					print("is problem here?") //no. tomorrow, add characterCount = 140 - textView.text!.characters.count somewhere in this method to fix the char count

					return false
				}
				textView.textColor = .black
				textView.text = ""
			}
			return true
		} else {
			textView.textColor = .darkGray
			textView.text = placeholderText
			let newPosition = textView.beginningOfDocument
			textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
			return false
		}
	}

}

