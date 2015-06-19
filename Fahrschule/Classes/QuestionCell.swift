//
//  QuestionCell.swift
//  Fahrschule
//
//  Created on 13.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.titleLabel.frame) + self.layoutMargins.left, 0, 0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.iconImageView.image = nil
    }

}
