//
//  ProgressCell.swift
//  Fahrschule
//
//  Created on 13.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ProgressCell: UITableViewCell {
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var horizontalMarginConstraint: NSLayoutConstraint!
    
    var progressViewWidth: CGFloat = 0.0
    var progressMargin: CGFloat = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.titleLabel.frame) + self.layoutMargins.left, 0, 0)
        progressViewWidth = self.widthConstraint.constant
        progressMargin = self.horizontalMarginConstraint.constant
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setProgressViewHidden(hidden: Bool) {
        if hidden {
            self.widthConstraint.constant = 0
            self.horizontalMarginConstraint.constant = 0
            self.layoutIfNeeded()
            
        } else {
            self.widthConstraint.constant = progressViewWidth
            self.horizontalMarginConstraint.constant = progressMargin
            self.layoutIfNeeded()
            
        }
    }
    
}
