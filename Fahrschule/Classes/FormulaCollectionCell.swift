//
//  FormulaCollectionCell.swift
//  Fahrschule
//
//  Created on 02.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class FormulaCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var formulaView: UIView!
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
}
