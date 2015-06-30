//
//  QuestionsTableViewController.swift
//  Fahrschule
//
//  Created on 18.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit



class QuestionsTableViewController: UITableViewController, UISearchResultsUpdating, UISplitViewControllerDelegate {

//    MARK: - Types
    struct MainStoryboard {
        struct SegueIdentifiers {
            static let showTestQuestions = "showTestQuestions"
            static let showExamQuestions = "showExamQuestions"
        }
        
        struct Restoration {
            static let subGroupKey = "SUBGROUP_STORE_KEY"
            static let titleKey = "QTVC_TITLE_KEY"
        }
        
        struct CellIdentifier {
            static let Learning = "Cell"
            static let Exam = "ExamCell"
        }
    }
    
//    MARK: Properties
    var detailNavigationController: UINavigationController?
    var questionSheetType: QuestionSheetType = .Learning
    var managedObjectContext: NSManagedObjectContext!
    var currentIndexPath: NSIndexPath?
    var dataSource: [QuestionModel]!
    var subGroup: SubGroup! {
        didSet {
            let moc = self.managedObjectContext == nil ? self.subGroup.managedObjectContext : self.managedObjectContext
            let questions = Question.questionsInRelationsTo(subGroup, inManagedObjectContext: moc) as [AnyObject]
            self.dataSource = QuestionModel.modelsForQuestions(questions) as? [QuestionModel]
            self.title = self.subGroup.name
        }
    }
    
    var localObservers = [AnyObject]()
    
//    MARK: - Initialization & Delocation
    deinit {
        unregisterObservers()
    }
    
  
//    MARK: - State Save and Preservation
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        coder.encodeObject(self.subGroup.objectID.URIRepresentation(), forKey: MainStoryboard.Restoration.subGroupKey)
        coder.encodeObject(self.title, forKey: MainStoryboard.Restoration.titleKey)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
//        Restore Subgroup
        self.managedObjectContext = SNAppDelegate.sharedDelegate().managedObjectContext
        
        let objURI = coder.decodeObjectForKey(MainStoryboard.Restoration.subGroupKey) as! NSURL
        let objID: NSManagedObjectID = self.managedObjectContext.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(objURI)!
        self.subGroup = self.managedObjectContext.objectWithID(objID) as! SubGroup
        
//        Restore controller title
        self.title = coder.decodeObjectForKey(MainStoryboard.Restoration.titleKey) as? String
        
    }
    
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Observers
        regisgerObservers()
        
        // TableView settings
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.estimatedRowHeight = 44.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
//    MARK: - Observers
    func regisgerObservers() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        
        
        // Highlight answered question
        localObservers.append(center.addObserverForName(SettingsNotificationDidChangeAnswersGiven, object: nil, queue: queue, usingBlock: {
            [weak self] note in
            
            if let model = note.object as? QuestionModel {
                
                if let array = self?.dataSource {
                    if let idx = find(array, model ) {
                        let indexPath = NSIndexPath(forRow: idx, inSection: 0)
                        if let cell = self?.tableView.cellForRowAtIndexPath(indexPath) as? QuestionCell {
                            cell.setAnswerGiven(true, animated: true)
                        }
                    }
                }
            }
        }))

        
        // Select current question
        localObservers.append(center.addObserverForName(SettingsNotificationDidSelectQuestion, object: nil, queue: queue, usingBlock: {
            [weak self] note in
            
            if let indexPath = note.object as? NSIndexPath {
                let arr = self?.tableView.indexPathsForVisibleRows() as! [NSIndexPath]
                
                var scrollPosition: UITableViewScrollPosition = .None
                
                if indexPath.compare(arr.first!) == .OrderedAscending {
                    scrollPosition = .Top
                }
                else if indexPath.compare(arr.last!) == .OrderedDescending {
                    scrollPosition = .Bottom
                }
                
                self?.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: scrollPosition)

            }
            
        }))
        
        
        
    }
    
    func unregisterObservers() {
        let center = NSNotificationCenter.defaultCenter()
        for observer in self.localObservers {
            center.removeObserver(observer)
        }
    }
    
//    MARK: - Private functions
    func didChangeAnswersGiven(note: NSNotification) {
        
        
        
    }
    
//    MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if identifier == MainStoryboard.SegueIdentifiers.showExamQuestions || identifier == MainStoryboard.SegueIdentifiers.showTestQuestions  {
                if detailNavigationController != nil {
                    if detailNavigationController?.topViewController is QuestionSheetViewController {
                        let qsvc = detailNavigationController?.topViewController as! QuestionSheetViewController
//                        qsvc.currentIndexPath = self.tableView.indexPathForSelectedRow()!
                        qsvc.showQuestionAtIndexPath(self.tableView.indexPathForSelectedRow()!)
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navController = segue.destinationViewController as? UINavigationController {
            if let qsvc = navController.topViewController as? QuestionSheetViewController {
                qsvc.managedObjectContext = self.managedObjectContext
                
                if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                    for model in self.dataSource {
                        model.givenAnswers = nil
                        model.hasSolutionBeenShown = false
                    }
                }
                
                if let cell = sender as? UITableViewCell {
                    qsvc.questionModels = self.dataSource
                    qsvc.currentIndexPath = self.tableView.indexPathForSelectedRow()!
                }
                else if let arr = sender as? [QuestionModel] {
                    qsvc.questionModels = arr
                }
                
                qsvc.questionSheetType = self.questionSheetType
                
            }
        }

    }

//    MARK: - Outlet functions
    @IBAction func didTapButtonQuery(sender: AnyObject) {

        let title = NSLocalizedString("Was soll abgefragt werden?", comment: "")
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Abbrechen", comment: ""), style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Fragen", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, inManagedObjectContext: self.managedObjectContext)
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showTestQuestions, sender: models)
            
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle falsch Beantworteten", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, state: .FaultyAnswered, inManagedObjectContext: self.managedObjectContext)
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            if models.count > 0 {
                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showTestQuestions, sender: models)
            }
            
        }))
        
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Unbeantworteten", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, state: .StateLess, inManagedObjectContext: self.managedObjectContext)
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            
            if models.count > 0 {
                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showTestQuestions, sender: models)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Falsch & Unbeantwortete", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, state: .FaultyAnswered, inManagedObjectContext: self.managedObjectContext)
            var models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            let lessQuestions = Question.questionsInRelationsTo(self.subGroup, state: .StateLess, inManagedObjectContext: self.managedObjectContext)
            models += QuestionModel.modelsForQuestions(lessQuestions) as! [QuestionModel]
            if models.count > 0 {
                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showTestQuestions, sender: models)
            }
        }))
        
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
//    MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let model = self.dataSource[indexPath.row]
        let question = model.question
        
        var cell: QuestionCell
        
        if self.questionSheetType != .Exam {
            cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifier.Learning, forIndexPath: indexPath) as! QuestionCell
            cell.numberLabel.text = question.number
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.CellIdentifier.Exam, forIndexPath: indexPath) as! QuestionCell
            cell.answerGiven = model.isAnAnswerGiven()
        }
        
        cell.titleLabel.text = question.text
        
        if question.learnStats != nil && question.learnStats.count > 0 && self.questionSheetType != .Exam {
            var set = question.learnStats as NSSet
            let arr = set.allObjects
            for learnStat in arr {
                let state = learnStat.state as NSNumber
                switch state.integerValue {
                case StatisticState.CorrectAnswered.rawValue:
                    cell.iconImageView!.image = UIImage(named: "richtig")
                case StatisticState.FaultyAnswered.rawValue:
                    cell.iconImageView!.image = UIImage(named: "falsch")
                default:
                    cell.iconImageView!.image = nil
                }
            }
        } else {
            cell.iconImageView.image = nil
        }
        
        
        return cell
        
    }
    
//   MARK:  - Search Results Updating delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // updateSearchResultsForSearchController(_:) is called when the controller is being dismissed to allow those who are using the controller they are search as the results controller a chance to reset their state. No need to update anything if we're being dismissed.
        if !searchController.active {
            return
        }
        
        let searchString = searchController.searchBar.text
        let questions = Question.questionsForSearchString(searchString, inManagedObjectContext: self.managedObjectContext) as? [Question]
        self.dataSource = QuestionModel.modelsForQuestions(questions) as? [QuestionModel]
        self.tableView.reloadData()
        
    }

}
