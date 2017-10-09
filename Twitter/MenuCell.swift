//
//  MenuCell.swift
//  HamburgerMenuExample
//
//  Created by Eden on 10/5/17.
//  Copyright © 2017 Eden Shapiro. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
