//
//  ProgressView.swift
//  Fahrschule
//
//  Created on 19.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var succedLayer: CALayer!
    var failedLayer: CALayer!
    
    var bkgLayer: CALayer!
    
    var progressItem: ProgressItem = ProgressItem() {
        didSet {
            self.reloadData()
        }
    }
    
    private func reloadData() {
        
        var succedWidth: CGFloat = 0.0
        var failedWidth : CGFloat = 0.0
        
        if self.progressItem.numOfQuestions > 0 {
            succedWidth = CGFloat(self.progressItem.correctAnswers) / CGFloat(self.progressItem.numOfQuestions) * CGRectGetWidth(self.bounds)
            failedWidth = CGFloat(self.progressItem.faultyAnswers) / CGFloat(self.progressItem.numOfQuestions) * CGRectGetWidth(self.bounds)
        }
        
        if failedLayer != nil {
            var frame = failedLayer.frame
            frame.size.width = succedWidth + failedWidth
            failedLayer.frame = frame
            
        }
        
        if succedLayer != nil {
            var frame = succedLayer.frame
            frame.size.width = succedWidth
            succedLayer.frame = frame
            
        }
    }

    //    MARK: Drawing
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bkgLayer == nil {
            bkgLayer = CALayer()
            bkgLayer.backgroundColor = backgroundColor?.CGColor
            layer.addSublayer(bkgLayer)
        }
        
        bkgLayer.frame = bounds
        
        
        
        if failedLayer == nil {
            failedLayer = CALayer()
            failedLayer.frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds))
            failedLayer.backgroundColor = UIColor.roseAshesColor().CGColor
            layer.addSublayer(failedLayer)
        }
        
        if succedLayer == nil {
            succedLayer = CALayer()
            succedLayer.frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds))
            succedLayer.backgroundColor = UIColor.lemonColor().CGColor
            layer.addSublayer(succedLayer)
        }
        
        
        self.reloadData()
        
    }
    

}
