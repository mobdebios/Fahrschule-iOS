//
//  LicenseCell.swift
//  Fahrschule
//
//  Created on 22.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class LicenseCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView()
        view.backgroundColor = UIColor.colorFromHex(0xf5f5f5, alpha: 1)
        self.selectedBackgroundView = view
        
    }
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
}
