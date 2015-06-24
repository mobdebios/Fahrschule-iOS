//
//  CircularChartView.swift
//  Fahrschule
//
//  Created on 11.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit
import QuartzCore

//@IBDesignable

class CircularChartView: UIView {

    /*@IBInspectable*/ var succeed : Int = 0
    /*@IBInspectable*/ var failed : Int = 0
    /*@IBInspectable*/ var remaining : Int = 0
    
    var lineWidth: CGFloat = 30.0
    
    
    
    var remainingLayer : CAShapeLayer!
    var falseLayer: CAShapeLayer!
    var trueLayer: CAShapeLayer!
    
    private var titleLabel: UILabel!
    var title: String? {
        didSet {
            self.titleLabel.text = title?.uppercaseString
        }
    }

    var subtitleLabel: UILabel!
    /*@IBInspectable*/ var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle?.uppercaseString
        }
    }
    
//    MARK: Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    private func initialize() {
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.font = UIFont.helveticaNeueRegular(30)
        titleLabel.textColor = UIColor.grayFont()
        titleLabel.backgroundColor = UIColor.clearColor()
        
        subtitleLabel = UILabel(frame: CGRectZero)
        subtitleLabel.font = UIFont.helveticaNeueRegular(17)
        subtitleLabel.textColor = UIColor.grayFont()
        subtitleLabel.backgroundColor = UIColor.clearColor()
        
        
    }
    
//    MARK: Drawing
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clearColor()
        
        let rect = CGRectInset(self.bounds, lineWidth / 2, lineWidth / 2)
        let path = UIBezierPath(ovalInRect: rect)

        if remainingLayer == nil {
            remainingLayer = CAShapeLayer();
            
            
            remainingLayer.fillColor = UIColor.clearColor().CGColor
            remainingLayer.lineWidth = lineWidth
            remainingLayer.borderColor = nil
            remainingLayer.strokeColor = UIColor.brickColor().CGColor
            self.layer .addSublayer(remainingLayer);
            
        }
        
        remainingLayer.path = path.CGPath
        remainingLayer.frame = self.bounds
        
        if falseLayer == nil {
            falseLayer = CAShapeLayer();
            layer.addSublayer(falseLayer);
            
            
            falseLayer.fillColor = UIColor.clearColor().CGColor
            falseLayer.lineWidth = lineWidth
            falseLayer.strokeColor = UIColor.roseAshesColor().CGColor
            
            falseLayer.anchorPoint = CGPointMake(0.5, 0.5)
            falseLayer.transform = CATransform3DRotate(falseLayer.transform, -CGFloat(M_PI_2), 0, 0, 1)
            falseLayer.strokeStart = 0.0
        }
        
        falseLayer.path = path.CGPath
        falseLayer.frame = self.bounds
        
        if trueLayer == nil {
            trueLayer = self.chartLayer(UIColor.lemonColor());
            layer.addSublayer(trueLayer)
        }
        trueLayer.path = path.CGPath
        trueLayer.frame = bounds
        
//        Title Label
        if titleLabel.superview == nil {
            self.addSubview(titleLabel)
        }
        
        titleLabel.text = "100%"
        titleLabel.sizeToFit()
        titleLabel.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - CGRectGetMidY(titleLabel.bounds))
        
        
//        Subtitle label
        if subtitleLabel.superview == nil {
            self.addSubview(subtitleLabel)
        }
        
        subtitleLabel.sizeToFit()
        subtitleLabel.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) + CGRectGetMidY(subtitleLabel.bounds))
        
        reloadData()
    }
    
    private func reloadData() {
        let total = self.succeed + self.failed + self.remaining
        trueLayer.strokeEnd = CGFloat(self.succeed) / CGFloat(total)
        falseLayer.strokeEnd = trueLayer.strokeEnd + CGFloat(self.failed) / CGFloat(total)
        
        
        let per =  total > 0 ? Int(round(CGFloat(succeed + failed) / CGFloat(total) * 100)) : 0
        titleLabel.text = "\(per)%"
        
    }
    
    private func chartLayer(color: UIColor)->CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        let rect = CGRectInset(self.bounds, self.lineWidth / 2, self.lineWidth / 2)
        let path = UIBezierPath(ovalInRect: rect)
        
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.lineWidth = self.lineWidth
        shapeLayer.strokeColor = color.CGColor
        
        shapeLayer.anchorPoint = CGPointMake(0.5, 0.5)
        shapeLayer.transform = CATransform3DRotate(shapeLayer.transform, -CGFloat(M_PI_2), 0, 0, 1)
        shapeLayer.strokeStart = 0.0
        
        return shapeLayer
    }
    
    //    MARK: Storyboard
    override func prepareForInterfaceBuilder() {
        if succeed == 0 { succeed = 30 }
        if failed == 0 { failed = 20 }
        if remaining == 0 { remaining == 30}
        
        if subtitle == nil {
            subtitle = "subtitile"
        }
    }

}





















