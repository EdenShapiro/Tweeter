//
//  LoginVC.swift
//  Twitter
//
//  Created by Eden on 9/26/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


	@IBAction func onLoginButtonClicked(_ sender: Any) {
		TwitterClient.sharedInstance.login(success: {
			print("I've logged in!")
			self.performSegue(withIdentifier: "LoginSegue", sender: nil)
		}, failure: {error in
			print("Error in login: \(error)")
		})
		
	}
}
