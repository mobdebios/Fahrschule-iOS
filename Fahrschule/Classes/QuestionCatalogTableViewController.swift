//
//  QuestionCatalogTableViewController.swift
//  Fahrschule
//
//  Created 19.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class QuestionCatalogTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var lastUpdate = NSDate()
    var mainGroupArray: [MainGroup]!
    var dataSource: [MainGroup]!
    var numberOfThemes = [0, 0]
    var progressDict = [Int: ProgressItem]()
    var localObservers = [AnyObject]()
    
    var resultSearchController: UISearchController!
    
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
        self.registerObservers();
    }
    
    deinit {
        self.unregisterObservers()
    }
    
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Segmented control
        self.segmentedControl.setEnabled(false, forSegmentAtIndex: 1)

        // TableView settings
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
//            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        
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
        
        var statisticsLastUpdated = NSDate.distantPast() as! NSDate
        let stat = LearningStatistic.latestStatistic(self.managedObjectContext)
        if  stat != nil {
            statisticsLastUpdated = stat.date
        }
        
//        if self.isLearningMode == false {
//            if self.isCatalogSelected() {
//                
//            }
//        }
        
        if statisticsLastUpdated.earlierDate(self.lastUpdate).compare(self.lastUpdate) == .OrderedSame || stat == nil {
            self.progressDict.removeAll(keepCapacity: false)
            self.lastUpdate = NSDate()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.mainGroupArray.count != self.progressDict.count {
            for (i, element) in enumerate(self.mainGroupArray) {
                if self.progressDict[i] == nil {
                    self.progressItemForMainGroupAtIndex(i)
                }
            }
        }
        
    }
    
    //    MARK: - Observers
    private func registerObservers() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        
        
        self.localObservers.append(center.addObserverForName("tagQuestion", object: nil, queue: queue) {
            [weak self] _ in
            if let weakSelf = self {
                let questions = Question.taggedQuestionsInManagedObjectContext(weakSelf.managedObjectContext)
                if questions.count > 0 {
                    weakSelf.segmentedControl.setEnabled(true, forSegmentAtIndex: 1)
                } else {
                    weakSelf.segmentedControl.setEnabled(false, forSegmentAtIndex: 1)
                }
            }
            })
        
        
        self.localObservers.append(center.addObserverForName("licenseClassChanged", object: nil, queue: queue) {
            [weak self] _ in
            if let weakSelf = self {
                println("\(__FUNCTION__) not emplemented yet licenseClassChanged")
            }
            })
        
        self.localObservers.append(center.addObserverForName("didChangeAnswersGiven", object: nil, queue: queue) {
            [weak self] note in
            if let weakSelf = self {
                println("\(__FUNCTION__) not emplemented yet didChangeAnswersGiven")
            }
            })
        
    }
    
    private func unregisterObservers() {
        let center = NSNotificationCenter.defaultCenter()
        for observer in self.localObservers {
            center.removeObserver(observer)
        }
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
        
        var item = self.progressDict[idx]
        if item == nil  {
            item = self.progressItemForMainGroupAtIndex(idx)
        }
        cell.progressView.progressItem = item!
        
        return cell
    }
    
//    MARK: - Table View delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.isCatalogSelected() && !self.isSearching {
            self.performSegueWithIdentifier("SubGroupTableViewController", sender: self)
        }
    }
    
    
//    MARK: - Private Functions
    private func progressItemForMainGroupAtIndex(index: Int)->ProgressItem {
        let mainGroup = self.mainGroupArray[index]
        let item = ProgressItem()
        
        item.numOfQuestions = UInt(Question.countQuestionsInRelationsTo(mainGroup, inManagedObjectContext: self.managedObjectContext))
        if item.numOfQuestions > 0 {
            item.correctAnswers = LearningStatistic.countStatisticsInRelationsTo(mainGroup, inManagedObjectContext: self.managedObjectContext, showState: .CorrectAnswered)
            item.faultyAnswers = LearningStatistic.countStatisticsInRelationsTo(mainGroup, inManagedObjectContext: self.managedObjectContext, showState: .FaultyAnswered)
        }
        
        self.progressDict[index] = item
        return item
    }
    
    private func isCatalogSelected()->Bool {
        return self.segmentedControl.selectedSegmentIndex == 0
    }
    
    

}
