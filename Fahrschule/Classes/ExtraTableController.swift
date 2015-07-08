//
//  ExtraTableController.swift
//  Fahrschule
//
//  Created on 02.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ExtraTableController: UITableViewController {
    
//    MARK: - Types
    struct MainStoryboard {
        struct SegueIdentifiers {
            static let showStVO = "showStVO"
            static let showLicenseClass = "showLicenseClass"
            static let showFormulas = "showFormulas"
            static let showBrakingDistance = "showBrakingDistance"
            static let showTrafficSigns = "showTrafficSigns"
        }
        
        struct CellIdentifiers {
            static let mainCell = "Cell"
        }
    }
    
    
//    MARK: Properties
    var dataSource: [[String : String]]!
    
//    MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("Extras", ofType: "plist")
        self.dataSource = NSArray(contentsOfFile: path!) as! [[String : String]]
    
        self.clearsSelectionOnViewWillAppear = true
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            navigationItem.leftBarButtonItem = nil
        }
        
    }

//    MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifiers.mainCell, forIndexPath: indexPath) as! UITableViewCell
        let item = dataSource[indexPath.row]
        cell.textLabel!.text = item["title"]
        cell.imageView?.image = UIImage(named: item["image"]!)
        return cell
    }
    
//    MARK: - Table View datasource
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0:
            break
        case 1:
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showFormulas, sender: self)
        case 2:
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showBrakingDistance, sender: self)
        case 3:
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showTrafficSigns, sender: self)
        case 4:
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showStVO, sender: self)
            break
        default:
#if FAHRSCHULE_LITE
            let sURL = Settings.sharedSettings().iTunesLiteLink
#else
            let sURL = Settings.sharedSettings().iTunesLink
#endif
            UIApplication.sharedApplication().openURL(NSURL(string: sURL)!)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}
