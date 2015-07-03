//
//  BrakingDistanceViewController.swift
//  Fahrschule
//
//  Created on 02.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class BrakingDistanceViewController: UIViewController {

//    MARK: - Types
    struct UserDefaultsKeys {
       static let Velocity = "BrakingDistanceViewControllerVelocity"
    }
    
//    MARK: - Outlets
    
    @IBOutlet weak var buttonsContaierView: UIView!
    @IBOutlet weak var counterView: CircularCounterView!
    @IBOutlet weak var sliderView: UISlider!
    
    @IBOutlet weak var reactionDistanceLabel: UILabel!
    @IBOutlet weak var breakingDistanceNormalLabel: UILabel!
    @IBOutlet weak var breakingDistanceEmergencyLabel: UILabel!
    @IBOutlet weak var stoppingDistanceNormalLabel: UILabel!
    @IBOutlet weak var stoppingDistanceEmergencyLabel: UILabel!
    
//    MARK: Properties
    var breakingConstant: Int = 1
    
//    MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        counterView.title = NSLocalizedString("km", comment: "")
        
//        breakingConstant = 1
        
        sliderView.value = NSUserDefaults.standardUserDefaults().floatForKey(UserDefaultsKeys.Velocity)
        sliderValueChanged(sliderView)

    }

    
//    MARK: - Outlet functions
    @IBAction func didTapButtonWeather(sender: UIButton) {
        if sender.selected {
            return
        }
        
        if let button = buttonsContaierView.viewWithTag(breakingConstant) as? UIButton {
            button.selected = false
            
            let centerFrame = button.frame
            let sideFrame = sender.frame
            
            sender.bringSubviewToFront(buttonsContaierView)
            sender.selected = !sender.selected
            
            UIView.animateWithDuration(0.25, animations: { _ in
                sender.frame = centerFrame
                button.frame = sideFrame
                
            }, completion: { (finished) in
                self.breakingConstant = sender.tag
                self.sliderValueChanged(self.sliderView)
            })
            
        } else {
            sender.selected = !sender.selected
            breakingConstant = sender.tag
            sliderValueChanged(sliderView)
        }
        
        
    }
    
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        counterView.countLabel.text = "\(Int(sender.value))"
        counterView.setNeedsLayout()
        
//        let lengthFormatter = NSLengthFormatter()
//        lengthFormatter.numberFormatter.locale = NSLocale(localeIdentifier: "de_DE")
//        lengthFormatter.numberFormatter.maximumFractionDigits = 0
//        var val: Double = 0.3 * Double(sender.value)
//        reactionDistanceLabel.text = lengthFormatter.stringFromMeters(val)
        
        
        reactionDistanceLabel.text = "\(UInt(roundf(0.3 * sender.value))) m"
        breakingDistanceNormalLabel.text = "\( UInt(roundf((sender.value * 0.1) * (sender.value * 0.1) * Float(breakingConstant))) ) m"
        breakingDistanceEmergencyLabel.text = "\( UInt(roundf((sender.value * 0.1) * (sender.value * 0.1) * Float(breakingConstant)  * 0.5)) ) m"
        stoppingDistanceNormalLabel.text = "\( UInt(roundf(0.3 * sender.value + (sender.value * 0.1) * (sender.value * 0.1) * Float(breakingConstant))) ) m"
        stoppingDistanceEmergencyLabel.text = "\( UInt(roundf(0.3 * sender.value + (sender.value * 0.1) * (sender.value * 0.1) * Float(breakingConstant) * 0.5)) ) m"
        
        NSUserDefaults.standardUserDefaults().setFloat(sender.value, forKey: UserDefaultsKeys.Velocity)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    

}
