//
//  CircularCounterView.swift
//  Fahrschule
//
//  Created on 10.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

//@IBDesignable

class CircularCounterView: UIView {
    

    var backgroundLayer : CAShapeLayer!
    
//    /*@IBInspectable*/ var circleColor: UIColor = UIColor.lemonColor()
    
    var countLabel: UILabel!
    /*@IBInspectable*/ var counterValue : Int? {
        didSet {
            let num: NSNumber = counterValue!
            countLabel.text = num.stringValue
        }
    }
    
    var titleLabel: UILabel!
    /*@IBInspectable*/ var title : String? {
        didSet {
            titleLabel.text = title?.uppercaseString
        }
    }
    
    private func reload() {
//        var num: NSNumber = counterValue!
//        countLabel.text = num.stringValue
////        self.layoutSubviews()
    }
    
    // MARK: Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    private func initialize() {
        countLabel = UILabel(frame: CGRectZero)
        countLabel.font = UIFont.helveticaNeueRegular(30)
        countLabel.textColor = UIColor.whiteColor()
        countLabel.backgroundColor = UIColor.clearColor()
        self.addSubview(countLabel)
        
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.font = UIFont.helveticaNeueRegular(13)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.backgroundColor = UIColor.clearColor()
        self.addSubview(titleLabel)
        
    }
    

//    MARK: Drawing
    override func layoutSubviews() {
        super.layoutSubviews()
        
        super.backgroundColor = UIColor.clearColor()
        
        if backgroundLayer == nil {
            backgroundLayer = CAShapeLayer()
            self.layer.insertSublayer(backgroundLayer, atIndex: 0)
            backgroundLayer.fillColor = self.tintColor.CGColor
            let path = UIBezierPath(ovalInRect: self.bounds)
            backgroundLayer.path = path.CGPath
            
        }
        
        backgroundLayer.frame = self.bounds
        
        if countLabel.superview == nil {
            self.addSubview(countLabel)
        }
        
        countLabel.sizeToFit()
        countLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - CGRectGetMidY(countLabel.bounds))
        
        titleLabel.sizeToFit()
        titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + CGRectGetMidY(titleLabel.bounds))
        
        
    }
    
//    MARK: Storyboard
    override func prepareForInterfaceBuilder() {
        if counterValue == nil {
            counterValue = 30
        }
        
        if title == nil {
            title = "subtitile"
        }
    }

}
