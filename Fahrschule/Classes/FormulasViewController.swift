//
//  FormulasViewController.swift
//  Fahrschule
//
//  Created by Шурик on 02.07.15.
//  Copyright (c) 2015 Alexandr Zhovty. All rights reserved.
//

import UIKit


class FormulasViewController: UICollectionViewController {

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
    
//    MARK: Properties
    var dataSource: [[String: String]]!
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        let path = NSBundle.mainBundle().pathForResource("Formulas", ofType: "plist")!
        dataSource = NSArray(contentsOfFile: path)  as! [[String: String]]
    }

//    MARK: - Collection View datasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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


}
