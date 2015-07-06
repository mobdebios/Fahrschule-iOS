//
//  SplitViewController.swift
//  Fahrschule
//
//  Created on 06.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
//   Mark: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
//    MARK: - Split Controller delegate
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController _: UIViewController) -> Bool {
        
        // Master controller should be first in the stack
        return true
    }
   
}
