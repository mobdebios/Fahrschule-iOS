//
//  TrafficSignsCollectionCell.swift
//  Fahrschule
//
//  Created on 03.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class TrafficSignsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
}
