//
//  Appearance.swift
//  pocketfahrschule
//
//  Created by Alexandr Zhovty on 10.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class Appearance: NSObject {
   
    class func customizeAppearance() {
        let appDelegate : SNAppDelegate = UIApplication.sharedApplication().delegate as! SNAppDelegate
        appDelegate.window?.tintColor = UIColor.roseAshesColor()
        
        Appearance.customizeNavigationBar()
        Appearance.customizeTabBar()
    }
    
    class func customizeNavigationBar() {
        let navAppearance = UINavigationBar.appearance() as UINavigationBar
//        navAppearance.tintColor = UIColor.redColor()
        
        let attributes = [
            NSFontAttributeName : UIFont.helveticaNeueBold(17),
            NSForegroundColorAttributeName : UIColor.grayFont()
        ]
        
        navAppearance.titleTextAttributes = attributes
        
    }
    
    class func customizeTabBar() {
        let tabbarAppearance = UITabBar.appearance()
        tabbarAppearance.barTintColor = UIColor.grayTabBar()
    }
    
}
