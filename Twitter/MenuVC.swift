//
//  MenuVC.swift
//  HamburgerMenuExample
//
//  Created by Eden on 10/4/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!

	private var homeNavigationController: UINavigationController!
	private var mentionsNavigationController: UINavigationController!
	private var meNavigationController: UINavigationController!
	//Home, Mentions,  Me, accounts
	
	var viewControllers: [UINavigationController] = []
	var hamburgerVC: HamburgerVC!

	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		//			let vc = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")

		homeNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
		mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "MentionsNavigationController") as! UINavigationController

		meNavigationController = storyboard.instantiateViewController(withIdentifier: "MeNavigationController") as! UINavigationController

		
		if let user = User.currentUser {
			(meNavigationController.viewControllers.first as! ProfileVC).user = user
		}
		viewControllers.append(homeNavigationController)
		viewControllers.append(mentionsNavigationController)
		viewControllers.append(meNavigationController)
		
		hamburgerVC.contentViewController = homeNavigationController
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	

}

extension MenuVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
		
		let titles = ["Home", "Mentions", "Me"]
		cell.title.text = titles[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		hamburgerVC.contentViewController = viewControllers[indexPath.row]
	}
}
