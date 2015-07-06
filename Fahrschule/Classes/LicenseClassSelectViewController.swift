//
//  LicenseClassSelectViewController.swift
//  Fahrschule
//
//  Created on 22.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class LicenseClassSelectViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var licenseClassesDict:  NSDictionary?
    var keyList = ["1", "2", "8192", "16384", "4", "8", "16", "32", "64", "128", "512", "1024", "4096"]
    let checkedImage = UIImage(named: "bestanden")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        let path = NSBundle.mainBundle().pathForResource("LicenseClasses", ofType: "plist")
        self.licenseClassesDict = NSDictionary(contentsOfFile: path!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    MARK: - Table view data source

    override func  collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.keyList.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! LicenseCell
        
        let licenseClass = self.keyList[indexPath.row]
        let dict: NSDictionary = self.licenseClassesDict?.objectForKey(licenseClass) as! NSDictionary
        cell.titleLabel?.text = dict["title"] as? String
        cell.subtitleLabel?.text = dict["desc"] as? String
        cell.classLabel?.text = dict["class"] as? String
        
        
        let imageName: String = dict["image"] as! String
        let image = UIImage(named: imageName)
        
        if image != nil {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = nil
            println("\(imageName)")
        }
        
//        let settings = Settings.sharedSettings() as! Settings
//        let lc = settings.licenseClass as LicenseClass
        
        
        if licenseClass.toInt() == Settings.sharedSettings()!.licenseClass.rawValue {
            cell.iconImageView.image = checkedImage
        } else {
            cell.iconImageView.image = nil
        }
        
        
        
        return cell
    }
    
//    MARK: Collection View Delegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let settings = Settings.sharedSettings() as! Settings
        let oldValue = settings.licenseClass as LicenseClass
        let newValue: Int = self.keyList[indexPath.item].toInt()!
        if newValue != oldValue.rawValue {
            settings.licenseClass = LicenseClass(rawValue: newValue)!
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! LicenseCell
            cell.iconImageView.image = checkedImage
            
            if let idx = find(self.keyList, String(oldValue.rawValue)) {
                let oldIndexPath = NSIndexPath(forItem: idx, inSection: 0)
                if let oldCell = collectionView.cellForItemAtIndexPath(oldIndexPath) as? LicenseCell  {
                    oldCell.iconImageView.image = nil
                }
            }
                        
            if settings.licenseClass == .LicenseClassC1 || settings.licenseClass == .LicenseClassC || settings.licenseClass == LicenseClass.LicenseClassCE || settings.licenseClass == .LicenseClassD1 || settings.licenseClass == .LicenseClassD {
                
                settings.teachingType = .AdditionalLicense
            }
            else if settings.licenseClass == .LicenseClassMOFA {
                settings.teachingType = .FirstTimeLicense
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
//    MARK: - Collection View Flowlayout delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? CGRectGetWidth(collectionView.bounds) : CGRectGetWidth(collectionView.bounds) / 2.0
        return CGSizeMake(width, 44.0)
    }


}
