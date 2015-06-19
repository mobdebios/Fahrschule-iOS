//
//  UIViewController+Extension.swift
//  Fahrschule
//
//  Created by Alexandr Zhovty on 15.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func isIPAD()->Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    func isIPhone()->Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }
    
}
