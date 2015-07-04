//
//  SettingsViewController.swift
//  Fahrschule
//
//  Created on 04.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
//    MARK: - Types
    struct MainStoryboard {
        struct SegueIdentifiers {
            static let ShowLicenseClasses = "ShowLicenseClasses"
            static let ShowTeachingType = "ShowTeachingType"
        }
    }
//    MARK: Outlets
    @IBOutlet weak var licenseClassLabel: UILabel!
    @IBOutlet weak var teachingTypeLabel: UILabel!
    
//    MARK: Properties
    var localObservser = [AnyObject]()
    var licenseClassesDict: NSDictionary!
    
//    MARK: - Initialization & Dealocation
    deinit {
        unregisterObservers()
    }
    
//    MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false

        let path = NSBundle.mainBundle().pathForResource("LicenseClasses", ofType: "plist")!
        licenseClassesDict = NSDictionary(contentsOfFile: path)
        
        
        updateLicenseClassLabel()
        updateTeachingTypeLabel()
        
        registerObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

//    MARK: - Observers
    func registerObservers() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.addObserver(self, forKeyPath: SettingsLicenseClassKey, options: .New, context: nil)
        defaults.addObserver(self, forKeyPath: SettingsTeachingTypeKey, options: .New, context: nil)
    }
    
    func unregisterObservers() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObserver(self, forKeyPath: SettingsLicenseClassKey)
        defaults.removeObserver(self, forKeyPath: SettingsTeachingTypeKey)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case SettingsLicenseClassKey:
            updateLicenseClassLabel()
            
        case SettingsTeachingTypeKey:
            updateTeachingTypeLabel()
            
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
//    MARK: - Private functions
    private func updateLicenseClassLabel() {
        let keyPath = "\(Settings.sharedSettings().licenseClass.rawValue).class"
        licenseClassLabel.text = licenseClassesDict.valueForKeyPath(keyPath) as? String
    }
    
    private func updateTeachingTypeLabel() {
        teachingTypeLabel.text = Settings.sharedSettings().teachingType == .FirstTimeLicense ? NSLocalizedString("Ersterwerb", comment: "") : NSLocalizedString("Erweiterung", comment: "")
    }
    
//    MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let settings = Settings.sharedSettings() as! Settings
        if settings.hasSeenLicenseClassChangeMessage() == false {
            let msg = NSLocalizedString("Bitte beachte: jede Führerscheinklasse und jeder Erwerbstyp verfügt über ein separates Prüfungsarchiv inklusive Statistik. Jede Führerscheinklasse hat zudem ein eigenes „Markierte“-Fragenarchiv.", comment: "")
            let alertController = UIAlertController(title: "", message: msg, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        if segue.identifier == MainStoryboard.SegueIdentifiers.ShowLicenseClasses {

            //TODO: - I think it's uneccessary
            settings.lastActiveSettingsView = .LicenseClassSelectorView;
        }
        else if segue.identifier == MainStoryboard.SegueIdentifiers.ShowTeachingType {
            
            //TODO: - I think it's uneccessary
            settings.lastActiveSettingsView = .TeachingTypeSelectorView
        }
    }

}
