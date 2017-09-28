//
//  TweetsVC.swift
//  Twitter
//
//  Created by Eden on 9/25/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class TweetsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var tableView: UITableView!
	var tweets: [Tweet] = [Tweet]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		
		TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) in
			self.tweets = tweets
			self.tableView.reloadData()	
		}, failure: { (Error) in
			print("Could not find tweets")
		})
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return tweets.count
	}
	
	@IBAction func logoutButtonClicked(_ sender: Any) {
		TwitterClient.sharedInstance.logout()
	}


}


extension UIColor {
	
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
	convenience init(netHex:Int) {
		self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
	}
	
	struct TwitterColors {
		static let Blue = UIColor(netHex: 0x00ACED)
		static let DarkBlue = UIColor(netHex: 0x0084B4)
		static let VerifiedBlue = UIColor(netHex: 0x1dcaff)
		static let BackgroundBlue = UIColor(netHex: 0xc0deed)
	}
}
