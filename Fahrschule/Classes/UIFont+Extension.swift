//
//  Font+Customization.swift
//  pocketfahrschule
//
//  Created on 10.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    class func helveticaNeueRegular(size: CGFloat) ->UIFont {
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    
    class func helveticaNeueMedium (size: CGFloat) -> UIFont{
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    
    class func helveticaNeueBold (size: CGFloat) ->UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    
}
