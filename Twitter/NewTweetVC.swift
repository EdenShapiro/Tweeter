//
//  NewTweetVC.swift
//  Twitter
//
//  Created by Eden on 9/27/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class NewTweetVC: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var profilePictureImageView: UIImageView!

	@IBOutlet weak var cancelTweetButton: UIButton!
	
	@IBOutlet weak var tweetTextField: UITextField!
	
	var postTweetButton: UIBarButtonItem!
	var charCountViewItem: UIBarButtonItem!
	var characterCountView: UILabel!
	
	var characterCount = 140
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tweetTextField.delegate = self
		
		// Create toolBar
		let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = false
		
		let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		
		postTweetButton = UIBarButtonItem(title: "Tweet", style: .done, target: self, action: #selector(didPressTweetButton))
		characterCountView = UILabel()
		characterCountView.text = "\(characterCount)"
		characterCountView.sizeToFit()
		characterCountView.textColor = .darkGray
		characterCountView.backgroundColor = .clear
		let charCountViewItem = UIBarButtonItem(customView: characterCountView)
		if characterCount <= 0 {
			postTweetButton.isEnabled = false
		} else {
			postTweetButton.isEnabled = true
		}
		
		// Note, that we declared the `didPressDoneButton` to be called, when Done button has been pressed
		toolBar.items = [flexsibleSpace, charCountViewItem, postTweetButton]
		
		// Assing toolbar as inputAccessoryView
		tweetTextField.inputAccessoryView = toolBar
		
    }

	func didPressTweetButton(){
		
	}
	
	@IBAction func tweetFieldEditingChanged(_ sender: Any) {
		characterCount = 140 - tweetTextField.text!.characters.count
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
		tweetTextField.reloadInputViews()
	}

}
