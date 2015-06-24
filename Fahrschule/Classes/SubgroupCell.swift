//
//  SubgroupCell.swift
//  Fahrschule
//
//  Created on 13.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class SubgroupCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.titleLabel.frame) + self.layoutMargins.left, 0, 0)
//        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
//            self.accessoryType = .DisclosureIndicator
//            self.layoutSubviews()
//        }
        // Initialization code
    }

//    override func layoutSubviews() {
//        println("\(NSStringFromClass(UITableViewCell.self)) \(__FUNCTION__)")
//        contentView.frame = bounds
//        super.layoutSubviews()
//    }

}
