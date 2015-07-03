//
//  TrafficSignsViewController.swift
//  Fahrschule
//
//  Created by on 03.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class TrafficSignsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
//    MARK: - Types
    struct MainStoryboard {
        struct CellIdentifiers {
            static let MainCell = "Cell"
        }
    }
    
    struct DictionaryKeys {
        static let Image = "image"
        static let Text = "text"
    }
    
//    MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
//    MARK: Properties
    var dataSource: [[String: String]]!
    

//    MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("TrafficSigns", ofType: "plist")!
        self.dataSource = NSArray(contentsOfFile: path) as! [[String: String]]
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            previousButton.removeFromSuperview()
            nextButton.removeFromSuperview()
            
        } else {
            var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .Horizontal
            flowLayout.minimumInteritemSpacing = 0.0
            flowLayout.minimumLineSpacing = 0.0
            collectionView.pagingEnabled = true
            collectionView.collectionViewLayout = flowLayout
        }
        
    }
    
//    MARK: - Private functions
    private func stepForward(forward: Bool, animated: Bool) {
        
        var indexPath = self.collectionView.indexPathsForVisibleItems().first as! NSIndexPath
        
        if forward {
            indexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: indexPath.section)
        } else {
            indexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
        }
        
        if indexPath.item < 0 || indexPath.item >= self.dataSource.count {
            return
        }
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
        
        previousButton.enabled = indexPath.item > 0
        nextButton.enabled = indexPath.item < (dataSource.count - 1)
        
    }
    
//    MARK: - Outlet functions
    @IBAction func didTapButtonPrev(sender: AnyObject) {
        stepForward(false, animated: true)
    }
    
    @IBAction func didTapButtonNext(sender: AnyObject) {
        stepForward(true, animated: true)
    }
    

//    MARK: Collection View datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MainStoryboard.CellIdentifiers.MainCell, forIndexPath: indexPath) as! TrafficSignsCollectionCell
        let item = self.dataSource[indexPath.item]
        cell.textLabel.text = item[DictionaryKeys.Text]
        
        if let image = UIImage(named: item[DictionaryKeys.Image]!) {
            cell.imageView.image = UIImage(named: item[DictionaryKeys.Image]!)
        } else {
            println("\(item[DictionaryKeys.Image])")
        }
        
        return cell
    }
    
//    MARK: - Collection View Flowlayout delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width: CGFloat = CGRectGetWidth(collectionView.bounds)
        var height: CGFloat = CGRectGetHeight(collectionView.bounds) - collectionView.contentInset.top - collectionView.contentInset.bottom
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            width = width / 2
            height = height / 2
        }
        return CGSizeMake(width, height)
    }
    
//    MARK: - Scroll View delegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            let indexPath = collectionView.indexPathsForVisibleItems().last as! NSIndexPath
            previousButton.enabled = indexPath.item > 0
            nextButton.enabled = indexPath.item < (dataSource.count - 1)
        }
    }
}
