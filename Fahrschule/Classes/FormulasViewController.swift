//
//  FormulasViewController.swift
//  Fahrschule
//
//  Created on 02.07.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit


class FormulasViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

//    MARK: - Types
    struct MainStoryboard {
        struct CellIdentifiers {
            static let mainCell = "Cell"
        }
    }
    
    struct DictionaryKeys {
        static let title = "title"
        static let text = "text"
        static let formula = "formula"
        static let nibName = "nib"
    }
    
//    MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
//    MARK: Properties
    var dataSource: [[String: String]]!
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("Formulas", ofType: "plist")!
        dataSource = NSArray(contentsOfFile: path)  as! [[String: String]]
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .Horizontal
            flowLayout.minimumInteritemSpacing = 0.0
            flowLayout.minimumLineSpacing = 0.0
            collectionView.pagingEnabled = true
            collectionView.collectionViewLayout = flowLayout
            pageControl.numberOfPages = dataSource.count

        } else {
            
            
            
            pageControl.removeFromSuperview()
        }
    }

//    MARK: - Collection View datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MainStoryboard.CellIdentifiers.mainCell, forIndexPath: indexPath) as! FormulaCollectionCell
    
        let item = dataSource[indexPath.item]
        cell.titleLabel.text = item[DictionaryKeys.title]
        cell.textLabel.text = item[DictionaryKeys.text]

        for view in cell.formulaView.subviews {
            view.removeFromSuperview()
        }
        
        if let nibName = item[DictionaryKeys.nibName] {
            if let view = NSBundle.mainBundle().loadNibNamed(nibName, owner: 0, options: nil)[0] as? UIView {
                cell.formulaView.addSubview(view)
            }
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
            pageControl.currentPage = indexPath.item
        }
    }

}
