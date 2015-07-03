//
//  ExtrasViewController.swift
//  Fahrschule
//
//  Created on 01.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ExtrasViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
//    MARK: - Types
    struct MainStoryboard {
        struct SegueIdentifiers {
            static let StartExam = "StartExam"
        }
        
        struct CellIdentifiers {
            static let mainCell = "Cell"
        }
        
        struct IndexPath {
            static let Instructions = NSIndexPath(forItem: 0, inSection: 0)
            static let Rate = NSIndexPath(forItem: 5, inSection: 0)
        }
    }
    
//    MARK: Properties
    var dataSource: [[String : String]]!
    
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        
        let bundle = NSBundle.mainBundle()
        #if FAHRSCHULE_LITE
            let path = bundle.pathForResource("ExtrasLite", ofType: "plist")
            #else
            let path = bundle.pathForResource("Extras", ofType: "plist")
        #endif

        self.dataSource = NSArray(contentsOfFile: path!) as! [[String : String]]
        
        
    }


//    MARK: - Navigation
    @IBAction func exitToExtrasViewController(sender: UIStoryboardSegue) {}
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        let indexPath = self.collectionView?.indexPathsForSelectedItems().first as! NSIndexPath
        
        switch indexPath {
        case MainStoryboard.IndexPath.Instructions:
            self.collectionView?.deselectItemAtIndexPath(indexPath, animated: true)
            return false
            
        case MainStoryboard.IndexPath.Rate:
            #if FAHRSCHULE_LITE
                let sURL = Settings.sharedSettings().iTunesLiteLink
            #else
                let sURL = Settings.sharedSettings().iTunesLink
            #endif
            UIApplication.sharedApplication().openURL(NSURL(string: sURL)!)
            self.collectionView?.deselectItemAtIndexPath(indexPath, animated: true)
            return false
            
        default:
            return true
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let splitController = segue.destinationViewController as? UISplitViewController {
            let masterNavController = splitController.viewControllers.first as? UINavigationController
            let extraController = masterNavController?.topViewController as! ExtraTableController
            extraController.dataSource = self.dataSource
            
        }
    }
    
//    MARK: - Collection Veiw Datasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MainStoryboard.CellIdentifiers.mainCell, forIndexPath: indexPath) as! ExtraCollectionCell
        let item = self.dataSource[indexPath.row]
        cell.textLabel.text = item["title"]
        println("\(cell.textLabel.text)")
        let imageName = item["image"]
        
        if let image = UIImage(named: imageName!) {
            cell.imageView.image = image
        } else {
            println("\(imageName)")
        }
        
        return cell
    }
    
//    MARK: - Collection View Flowlayout delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? CGRectGetWidth(collectionView.bounds) : CGRectGetWidth(collectionView.bounds) / 2.0
        return CGSizeMake(width - 1.0, 44.0)
    }
    
    

}