//
//  ProgressView.swift
//  Fahrschule
//
//  Created on 19.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var succedLayer: UIView!
    var failedLayer: UIView!
    
    var progressItem: ProgressItem = ProgressItem() {
        didSet {
            self.reloadData()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.failedLayer = UIView(frame: CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds)))
        self.failedLayer.backgroundColor = UIColor.roseAshesColor()
        self.addSubview(self.failedLayer)
        
        self.succedLayer = UIView(frame: CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds)))
        self.succedLayer.backgroundColor = UIColor.lemonColor()
        self.addSubview(self.succedLayer)
        
        
    }
//
//    required override init(frame: CGRect) {
//        self.progressValue = ProgressItem()
//        super.init(frame: frame)
//    }
    
    private func reloadData() {
        
        var succedWidth: CGFloat = 0.0
        var failedWidth : CGFloat = 0.0
        
        if self.progressItem.numOfQuestions > 0 {
            succedWidth = CGFloat(self.progressItem.correctAnswers) / CGFloat(self.progressItem.numOfQuestions) * CGRectGetWidth(self.bounds)
            failedWidth = CGFloat(self.progressItem.faultyAnswers) / CGFloat(self.progressItem.numOfQuestions) * CGRectGetWidth(self.bounds)
        }
        
        var frame = self.succedLayer.frame
        frame.size.width = succedWidth
        self.succedLayer.frame = frame
        
        frame = self.failedLayer.frame
        frame.size.width = succedWidth + failedWidth
        self.failedLayer.frame = frame
        
        
    }

    //    MARK: Drawing
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        if failedLayer == nil {
//            failedLayer = UIView(frame: CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds)))
//            failedLayer.backgroundColor = UIColor.roseAshesColor()
//            self.addSubview(failedLayer)
//        }
//        
//        if succedLayer == nil {
//            succedLayer = UIView(frame: CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds)))
//            succedLayer.backgroundColor = UIColor.lemonColor()
//            self.addSubview(succedLayer)
//        }
//        
//        
        self.reloadData()
        
    }
    

}
