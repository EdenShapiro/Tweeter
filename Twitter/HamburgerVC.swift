//
//  HamburgerVC.swift
//  Twitter
//
//  Created by Eden on 10/3/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class HamburgerVC: UIViewController {
	
	@IBOutlet weak var menuView: UIView!
	@IBOutlet weak var contentView: UIView!
	
	@IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
	var originalLeftMargin: CGFloat!
	var menuViewController: UIViewController! {
		didSet {
			view.layoutIfNeeded()
			
//			if oldContentViewController != nil {
//				oldContentViewController.willMove(toParentViewController: nil)
//				oldContentViewController.view.removeFromSuperview()
//				oldContentViewController.didMove(toParentViewController: nil)
//			}
			
			menuViewController.willMove(toParentViewController: self)
			menuView.addSubview(menuViewController.view)
			menuViewController.didMove(toParentViewController: self)
		}
	}
	
	var contentViewController: UIViewController! {
		didSet(oldContentViewController) {
			view.layoutIfNeeded()
			
			if oldContentViewController != nil {
				oldContentViewController.willMove(toParentViewController: nil)
				oldContentViewController.view.removeFromSuperview()
				oldContentViewController.didMove(toParentViewController: nil)
			}
			
			contentViewController.willMove(toParentViewController: self)
			contentView.addSubview(contentViewController.view)
			contentViewController.didMove(toParentViewController: self)
			
			UIView.animate(withDuration: 0.3) { () -> Void in
				self.leftMarginConstraint.constant = 0
				self.view.layoutIfNeeded()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	@IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
		let translation = sender.translation(in: view)
		let velocity = sender.velocity(in: view)
		
		if sender.state == UIGestureRecognizerState.began {
			originalLeftMargin = leftMarginConstraint.constant
		} else if sender.state == UIGestureRecognizerState.changed {
			leftMarginConstraint.constant = originalLeftMargin + translation.x
		} else if sender.state == UIGestureRecognizerState.ended {
			
			UIView.animate(withDuration: 0.3, animations: {
				if velocity.x > 0 { //opening menu
					self.leftMarginConstraint.constant = self.view.frame.size.width - 50
				} else { //closing menu
					self.leftMarginConstraint.constant = 0
				}
				self.view.layoutIfNeeded()
			})
			
		}
	}
	
	
	
	
}
