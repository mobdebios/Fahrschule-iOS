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
    
    var answerGiven: Bool = false {
        didSet { configureView() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.titleLabel.frame) + self.layoutMargins.left, 0, 0)
    }
    
    private func configureView() {
        if answerGiven {
            titleLabel.alpha = 0.6
        } else {
            titleLabel.alpha = 1
        }
    }
    
    func setAnswerGiven(value: Bool, animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.answerGiven = value
            })
        } else {
            self.answerGiven = value
        }
    }
    
    

}
