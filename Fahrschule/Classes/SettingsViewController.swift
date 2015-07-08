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
            static let ShowImpressum = "ShowImpressum"
        }
        
        struct IndexPathes {
            static let DrivingLicense = NSIndexPath(forRow: 0, inSection: 0)
            static let Purchase = NSIndexPath(forRow: 1, inSection: 0)
            static let DeleteStastic = NSIndexPath(forRow: 1, inSection: 1)
        }
        
    }
//    MARK: Outlets
    @IBOutlet weak var licenseClassLabel: UILabel!
    @IBOutlet weak var teachingTypeLabel: UILabel!
    @IBOutlet weak var guestSwitch: UISwitch!
    
    
    
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
        

        let path = NSBundle.mainBundle().pathForResource("LicenseClasses", ofType: "plist")!
        licenseClassesDict = NSDictionary(contentsOfFile: path)
        
        
        updateLicenseClassLabel()
        updateTeachingTypeLabel()
        registerObservers()

        guestSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(SettingsGuestModeKey)
        
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            tableView.allowsMultipleSelection = true
            self.clearsSelectionOnViewWillAppear = false
            tableView.selectRowAtIndexPath(MainStoryboard.IndexPathes.DrivingLicense, animated: false, scrollPosition: .None)
        } else {
            tableView.allowsMultipleSelection = false
            self.clearsSelectionOnViewWillAppear = true
        }
        
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
        
        if segue.identifier == MainStoryboard.SegueIdentifiers.ShowImpressum {
            tableView.deselectRowAtIndexPath(MainStoryboard.IndexPathes.DrivingLicense, animated: true)
            tableView.deselectRowAtIndexPath(MainStoryboard.IndexPathes.Purchase, animated: true)
            
            
        } else {
            let settings = Settings.sharedSettings() as! Settings
            if settings.hasSeenLicenseClassChangeMessage() == false {
                let msg = NSLocalizedString("Bitte beachte: jede Führerscheinklasse und jeder Erwerbstyp verfügt über ein separates Prüfungsarchiv inklusive Statistik. Jede Führerscheinklasse hat zudem ein eigenes „Markierte“-Fragenarchiv.", comment: "")
                let alertController = UIAlertController(title: "", message: msg, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in
                    self.performSegueWithIdentifier(segue.identifier, sender: self)
                }))
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
    
//    MARK - Outlet functions
    @IBAction func guestValueChanged(sender: UISwitch) {
        let settings = Settings.sharedSettings() as! Settings
        settings.guestMode = sender.on
    }
    
//    MARK: - Table View delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath {
        case MainStoryboard.IndexPathes.DeleteStastic:
            let msg = NSLocalizedString("Möchtest du wirklich die Lernstatistiken der aktuellen Klasse zurücksetzen?", comment: "")
            let alertControler = UIAlertController(title: "", message: msg, preferredStyle: .Alert)
            
            alertControler.addAction(UIAlertAction(title: NSLocalizedString("Nein", comment: ""), style: .Cancel, handler: { _ in
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }))
            
            alertControler.addAction(UIAlertAction(title: NSLocalizedString("Ja", comment: ""), style: .Default, handler: { _ in
                LearningStatistic.statisticsResetInManagedObjectContext(SNAppDelegate.sharedDelegate().managedObjectContext)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }))

            presentViewController(alertControler, animated: true, completion: nil)
            
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            switch indexPath {
            case MainStoryboard.IndexPathes.DrivingLicense:
                tableView.deselectRowAtIndexPath(MainStoryboard.IndexPathes.Purchase, animated: true)
            case MainStoryboard.IndexPathes.Purchase:
                tableView.deselectRowAtIndexPath(MainStoryboard.IndexPathes.DrivingLicense, animated: true)
            default: break
            }
        }
        return indexPath
    }
    

}
