//
//  ModalSegue.swift
//  Fahrschule
//
//  Created by Шурик on 23.06.15.
//  Copyright (c) 2015 Alexandr Zhovty. All rights reserved.
//

import UIKit

class ModalSegue: UIStoryboardSegue {
    
    override func perform() {
        
        print("\(__FUNCTION__)")
        
        let sourceViewController = self.sourceViewController as! UIViewController
        let destinationViewController = self.destinationViewController as! UIViewController
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
        } else {
            // Select current tab
            let tabBarController = SNAppDelegate.sharedDelegate().window.rootViewController as! UITabBarController
            let splitController = tabBarController.selectedViewController as! UISplitViewController
            splitController.showDetailViewController(destinationViewController, sender: self)
            
        }
    }
   
}
