//
//  Color+Customization.swift
//  pocketfahrschule
//
//  Created by Alexandr Zhovty on 10.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func lemonColor()->UIColor {
        return UIColor.colorFromHex(0xc0ca33, alpha: 1)
    }
    
    class func brickColor()->UIColor {
        return UIColor.colorFromHex(0x616161, alpha: 1)
    }
    
    class func roseAshesColor()->UIColor {
        return UIColor.colorFromHex(0xeb7571, alpha: 1)
    }
    
    class func grayIcon()->UIColor {
        return UIColor.colorFromHex(0xbdbdbd, alpha: 1)
    }
    
    class func grayStatusBar()->UIColor {
        return UIColor.colorFromHex(0xe0e0e0, alpha: 1)
    }
    
    class func grayTabBar()->UIColor {
        return UIColor.colorFromHex(0xf5f7f5, alpha: 1)
    }
    
    class func grayFont()->UIColor {
        return UIColor.colorFromHex(0x212121, alpha: 1)
    }
    
    class func grayInactive()->UIColor{
        return UIColor.colorFromHex(0xababab, alpha: 1)
    }
    
    class func grayList()->UIColor {
        return UIColor.colorFromHex(0xebebeb, alpha: 1)
    }
    
    class func colorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    
    
}

