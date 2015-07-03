//
//  MarginLabel.swift
//  Fahrschule
//
//  Created by Шурик on 03.07.15.
//  Copyright (c) 2015 Alexandr Zhovty. All rights reserved.
//

import UIKit

@IBDesignable

class MarginLabel: UILabel {

    override func drawTextInRect(rect: CGRect) {
        var insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
        
    }

}
