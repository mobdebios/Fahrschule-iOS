//
//  TeachingTypeViewController.swift
//  Fahrschule
//
//  Created on 04.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class TeachingTypeViewController: UITableViewController {
    
//    MARK: - Types
//    MARK: Outlets
    @IBOutlet weak var firstPurchaseCell: UITableViewCell!
    @IBOutlet weak var extensionCell: UITableViewCell!

//    MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        let settings = Settings.sharedSettings() as! Settings
        switch settings.teachingType {
        case TeachingType.FirstTimeLicense:
            firstPurchaseCell.accessoryType = .Checkmark
            extensionCell.accessoryType = .None
            
        case TeachingType.AdditionalLicense:
            firstPurchaseCell.accessoryType = .None
            extensionCell.accessoryType = .Checkmark

        case TeachingType.UnknownTeachingType:
            firstPurchaseCell.accessoryType = .None
            extensionCell.accessoryType = .None
        
        }

    }

//    MARK: - Table View delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let settings = Settings.sharedSettings() as! Settings
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        switch cell {
        case firstPurchaseCell where firstPurchaseCell.accessoryType == .None:
            firstPurchaseCell.accessoryType = .Checkmark
            extensionCell.accessoryType = .None
            settings.teachingType = .FirstTimeLicense
            
        case extensionCell where extensionCell.accessoryType == .None:
            firstPurchaseCell.accessoryType = .None
            extensionCell.accessoryType = .Checkmark
            settings.teachingType = .AdditionalLicense
            
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

}
