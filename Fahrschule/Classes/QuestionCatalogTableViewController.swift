//
//  QuestionCatalogTableViewController.swift
//  Fahrschule
//
//  Created by Шурик on 19.06.15.
//  Copyright (c) 2015 Alexandr Zhovty. All rights reserved.
//

import UIKit

class QuestionCatalogTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var lastUpdate: NSDate!
    var mainGroupArray: [MainGroup]!
    var dataSource: [MainGroup]!
    var numberOfThemes = [0, 0]
    
    /// TODO: - Check neccessity
    var isSearching: Bool = false
    var isLearningMode: Bool = false
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Constatns
    let progressCellIdentifier = "progressCellIdentifier"
    let NUM_OF_SECTIONS = 2
    
//    MARK: Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("tagQuestion"), name: "tagQuestion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("licenseClassChanged"), name: "licenseClassChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didChangeAnswersGiven:"), name: "didChangeAnswersGiven", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView settings
        self.tableView.registerNib(UINib(nibName: "ProgressCell", bundle: nil), forCellReuseIdentifier: progressCellIdentifier)
        self.tableView.estimatedRowHeight = 44.0
        
        // Grouprs
        if self.managedObjectContext == nil {
            self.managedObjectContext = SNAppDelegate.sharedDelegate().managedObjectContext
        }
        let moc = self.managedObjectContext as NSManagedObjectContext
        
        var mainGroupsArray = [MainGroup]()
        let mainGroups = MainGroup.mainGroupsInManagedObjectContext(self.managedObjectContext) as! [MainGroup]
        for mainGroup in mainGroups {
            let numOfQuestions = Question.countQuestionsInRelationsTo(mainGroup, inManagedObjectContext: moc)
            if numOfQuestions > 0 {
                mainGroupsArray.append(mainGroup)
                if mainGroup.baseMaterial.boolValue == true {
                    numberOfThemes[0]++
                } else {
                    numberOfThemes[1]++
                }
            }
        }
        self.dataSource = mainGroupsArray
        self.mainGroupArray = self.dataSource
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
//        var statisticsLastUpdated = NSDate.distantPast() as! NSDate
//        if let stat = LearningStatistic.latestStatistic(self.managedObjectContext) {
//            statisticsLastUpdated = stat.date
//        }
//        
//        if self.isLearningMode == false {
//            if self.isCatalogSelected() {
//                
//            }
//        }
        
    }
    

//    MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SubGroupTableViewController {
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
            var offset = indexPath.section == 1 ? numberOfThemes[0] : 0
            offset += indexPath.row
            let mainGroup = self.dataSource[offset]
            vc.managedObjectContext = self.managedObjectContext
            vc.mainGroup = mainGroup
            vc.title = mainGroup.name
        }
    }
    
//    MARK: - Table View datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return self.isCatalogSelected()
        return NUM_OF_SECTIONS
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfThemes[section]
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Grundstoff", comment: "");
        case 1:
            return NSLocalizedString("Zusatzstoff", comment: "");
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(progressCellIdentifier) as! ProgressCell
        let idx = indexPath.section * numberOfThemes[0] + indexPath.row
        let mainGroup = self.dataSource[idx]
        cell.titleLabel.text = mainGroup.name
        cell.iconImageView.image = mainGroup.mainGroupImage()
        
        if cell.iconImageView.image == nil {
            println("\(__FUNCTION__) + \(mainGroup.image)")
        }
        
        return cell
    }
    
//    MARK: - Table View delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.isCatalogSelected() && !self.isSearching {
            self.performSegueWithIdentifier("SubGroupTableViewController", sender: self)
        }
    }
    
    
//    MARK: - Private Functions
    func licenseClassChanged() {
        
    }
    
    func didTagQuestion() {
        
    }
    
    func didChangeAnswersGiven(sender: AnyObject) {
        
    }
    
    private func isCatalogSelected()->Bool {
        return self.segmentedControl.selectedSegmentIndex == 0
    }
    
    

}
