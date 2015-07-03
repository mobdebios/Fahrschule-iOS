//
//  ExtraCollectionCell.swift
//  Fahrschule
//
//  Created on 01.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ExtraCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    

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
