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
        let destinationViewController = self.destinationViewController as! UINavigationController
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
        } else {
            // Select current tab
            
            println("\(__FUNCTION__) par: \(sourceViewController.parentViewController?.parentViewController)")
            
            let tabBarController = SNAppDelegate.sharedDelegate().window.rootViewController as! UITabBarController
            let splitController = tabBarController.selectedViewController as! UISplitViewController
            if let navController = splitController.viewControllers.last as? UINavigationController {
                navController.popToRootViewControllerAnimated(false)
                navController.pushViewController(destinationViewController.topViewController, animated: true)
            }
            
        }
    }
   
}
