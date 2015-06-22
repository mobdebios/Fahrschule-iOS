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
    var questionsController: UIViewController?
    
    
    
//    var searchSourceController: QuestionsTableViewController?
//    var resultSearchController: UISearchController!
    
    var searchController = UISearchController()
    
    /// TODO: - Check neccessity
    var isSearching: Bool = false
    var isLearningMode: Bool = false
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
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
        
//        println("\(self.searchDisplayController)")
        
        // Searh Results Controller
        let searchSourceController = self.storyboard!.instantiateViewControllerWithIdentifier("QuestionsTableViewController") as! QuestionsTableViewController
        searchSourceController.managedObjectContext = self.managedObjectContext
        searchSourceController.dataSource = [QuestionModel]()
        
        self.searchController = UISearchController(searchResultsController: searchSourceController)
        self.searchController.searchResultsUpdater = searchSourceController
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchController.searchBar
        
//        self.searchController.delegate = self;
        self.searchController.dimsBackgroundDuringPresentation = false
//        self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
        self.definesPresentationContext = true;  // know where you want UISearchController to be displayed
        
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
        
        // Segmented control
        let taggedQuestions: [Question] = (Question.taggedQuestionsInManagedObjectContext(self.managedObjectContext) as! [Question])
        self.segmentedControl.setEnabled(taggedQuestions.count > 0, forSegmentAtIndex: 1)
        
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
        else if segue.identifier == "QuestionSheetViewController" {
            if let navController = segue.destinationViewController as? UINavigationController {
                if let qsvc = navController.topViewController as? InquirerController {
                    qsvc.managedObjectContext = self.managedObjectContext
                    if let arr = sender as? [QuestionModel] {
                        qsvc.questionModels = arr
                    }
                }
            }
        }
    }
    
//    MARK: - Outlet functions
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        
        let side1Visible = self.segmentedControl.selectedSegmentIndex == 1
        
        if side1Visible {
            
            // Show QuestionsTableViewController with Tagged Questions
            let qtvc: QuestionsTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("QuestionsTableViewController") as! QuestionsTableViewController
            qtvc.view.hidden = true
            qtvc.managedObjectContext = self.managedObjectContext
            qtvc.tableView.contentInset = self.tableView.contentInset
            let taggedQuestions: [Question] = (Question.taggedQuestionsInManagedObjectContext(self.managedObjectContext) as! [Question])
            qtvc.dataSource = QuestionModel.modelsForQuestions(taggedQuestions) as! [QuestionModel]
            
            // Adding to controller to hierarchy
            self.addChildViewController(qtvc)
            qtvc.view.frame = self.containerView.bounds
            self.containerView.addSubview(qtvc.view)
            qtvc.didMoveToParentViewController(self)
            
            self.questionsController = qtvc
            
            // Present with animation
            let options = UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.TransitionFlipFromRight
            UIView.transitionWithView(self.containerView, duration: 1, options: options, animations: { () -> Void in
                self.tableView.hidden = true
                qtvc.view.hidden = false
            }, completion: nil)
            
        } else {
            
            let options = UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.TransitionFlipFromLeft
            
            UIView.transitionWithView(self.containerView, duration: 1, options: options, animations: { () -> Void in
                self.questionsController?.view.hidden = true
                self.tableView.hidden = false
            }, completion: { (finished) -> Void in
                
                self.questionsController?.willMoveToParentViewController(nil)
                self.questionsController?.view.removeFromSuperview()
                self.questionsController?.removeFromParentViewController()
                self.questionsController = nil
                
            })
        }
    }

    
    @IBAction func didTapButtonQuery(sender: AnyObject) {
        
        let title = NSLocalizedString("Was soll abgefragt werden?", comment: "")
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Abbrechen", comment: ""), style: .Cancel, handler: nil))
        
        
        // All questions
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Fragen", comment: ""), style: .Default, handler: { _ in
            var questions: [AnyObject]
            if self.isCatalogSelected() {
                questions = Question.questionsInRelationsTo(nil, inManagedObjectContext: self.managedObjectContext)
            } else {
                questions = Question.taggedQuestionsInManagedObjectContext(self.managedObjectContext)
            }
            
//            println("\(__FUNCTION__) questions count: \(questions.count)")
            
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            if questions.count > 0 {
                self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            }
            
        }))
        
        // Incorrect answered questions
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle falsch Beantworteten", comment: ""), style: .Default, handler: { _ in
            var questions: [AnyObject]
            if self.isCatalogSelected() {
                questions = Question.questionsInRelationsTo(nil, state: .FaultyAnswered, inManagedObjectContext: self.managedObjectContext)
            } else {
                questions = Question.taggedQuestionsInManagedObjectContext(self.managedObjectContext, state: .FaultyAnswered)
            }
            
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            if questions.count > 0 {
                self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            }
            
        }))
        
        // Unanswered questions
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Unbeantworteten", comment: ""), style: .Default, handler: { _ in
            var questions: [AnyObject]
            if self.isCatalogSelected() {
                questions = Question.questionsInRelationsTo(nil, state: .StateLess, inManagedObjectContext: self.managedObjectContext)
            } else {
                questions = Question.taggedQuestionsInManagedObjectContext(self.managedObjectContext, state: .StateLess)
            }
            
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            if questions.count > 0 {
                self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            }
            
        }))
        
        // Incorrect and Unanswered questions
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Falsch & Unbeantwortete", comment: ""), style: .Default, handler: { _ in
            var questions: [AnyObject]
            if self.isCatalogSelected() {
                questions = Question.questionsInRelationsTo(nil, state: .FaultyAnswered, inManagedObjectContext: self.managedObjectContext)
                questions += Question.questionsInRelationsTo(nil, state: .StateLess, inManagedObjectContext: self.managedObjectContext)
            } else {
                questions = Question.taggedQuestionsInManagedObjectContext(self.managedObjectContext, state: .FaultyAnswered)
                questions += Question.taggedQuestionsInManagedObjectContext(self.managedObjectContext, state: .StateLess)
            }
            
            var models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            
            if questions.count > 0 {
                self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            }
            
        }))
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
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
        let cell = self.tableView.dequeueReusableCellWithIdentifier(progressCellIdentifier) as! ProgressCell
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
    
//   MARK:  - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // updateSearchResultsForSearchController(_:) is called when the controller is being dismissed to allow those who are using the controller they are search as the results controller a chance to reset their state. No need to update anything if we're being dismissed.
        if !searchController.active {
            return
        }
        
        let filterString = searchController.searchBar.text
        println("\(__FUNCTION__) filterString: \(filterString)")
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
