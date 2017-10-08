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

    }


	@IBAction func onLoginButtonClicked(_ sender: Any) {
		TwitterClient.sharedInstance.login(success: {
			print("I've logged in!")
			self.performSegue(withIdentifier: "LoginSegue", sender: nil)
		}, failure: {error in
			print("Error in login: \(error)")
		})
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		print("in prep for segue")
		if segue.identifier == "LoginSegue" {
			
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
//			let hamburgerVC = storyboard.instantiateViewController(withIdentifier: "HamburgerVC") as! HamburgerVC
//			let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
//			
//			menuVC.hamburgerVC = hamburgerVC
//			hamburgerVC.menuViewController = menuVC
//			window?.rootViewController = hamburgerVC
			
			
			let hamburgerVC = segue.destination as! HamburgerVC
			let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
			menuVC.hamburgerVC = hamburgerVC
			hamburgerVC.menuViewController = menuVC
		}
	}
	
}
