//
//  QuestionsTableViewController.swift
//  Fahrschule
//
//  Created on 18.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit



class QuestionsTableViewController: UITableViewController {

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
    
//    Constatns
    let SUBGROUP_STORE_KEY = "SUBGROUP_STORE_KEY"
    let QTVC_TITLE_KEY = "QTVC_TITLE_KEY"
    
  
//    MARK: State Save and Preservation
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        coder.encodeObject(self.subGroup.objectID.URIRepresentation(), forKey: SUBGROUP_STORE_KEY)
        coder.encodeObject(self.title, forKey: QTVC_TITLE_KEY)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
//        Restore Subgroup
        self.managedObjectContext = SNAppDelegate.sharedDelegate().managedObjectContext
        
        let objURI = coder.decodeObjectForKey(SUBGROUP_STORE_KEY) as! NSURL
        let objID: NSManagedObjectID = self.managedObjectContext.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(objURI)!
        self.subGroup = self.managedObjectContext.objectWithID(objID) as! SubGroup
        
//        Restore controller title
        self.title = coder.decodeObjectForKey(QTVC_TITLE_KEY) as? String
        
    }
    
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didChangeAnswersGiven"), name: "didChangeAnswersGiven", object: nil)
        
        // TableView settings
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.estimatedRowHeight = 44.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
//    MARK: - Private functions
    func didChangeAnswersGiven() {
        println("\(NSStringFromClass(QuestionsTableViewController.self)) \(__FUNCTION__)")
    }
    
//    MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QuestionSheetViewController" {
            if let navController = segue.destinationViewController as? UINavigationController {
                if let qsvc = navController.topViewController as? InquirerController {
                    qsvc.managedObjectContext = self.managedObjectContext
                    
                    for model in self.dataSource {
                        model.givenAnswers = nil
                        model.hasSolutionBeenShown = false
                    }
                    
                    if let cell = sender as? UITableViewCell {
                        qsvc.questionModels = self.dataSource
                        qsvc.currentIndexPath = self.tableView.indexPathForSelectedRow()!
                    }
                    else if let arr = sender as? [QuestionModel] {
                        qsvc.questionModels = arr
                    }
                    
                }
            }
        }
    }

//    MARK: - Outlet functions
    @IBAction func didTapButtonQuery(sender: AnyObject) {
//        println("\(NSStringFromClass(QuestionsController)) \(__FUNCTION__)")
        
        let title = NSLocalizedString("Was soll abgefragt werden?", comment: "")
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Abbrechen", comment: ""), style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Fragen", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, inManagedObjectContext: self.managedObjectContext)
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle falsch Beantworteten", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, state: .FaultyAnswered, inManagedObjectContext: self.managedObjectContext)
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            if models.count > 0 {
                self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            }
            
        }))
        
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Unbeantworteten", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, state: .StateLess, inManagedObjectContext: self.managedObjectContext)
            let models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            
            if models.count > 0 {
                self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Falsch & Unbeantwortete", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.subGroup, state: .FaultyAnswered, inManagedObjectContext: self.managedObjectContext)
            var models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
            let lessQuestions = Question.questionsInRelationsTo(self.subGroup, state: .StateLess, inManagedObjectContext: self.managedObjectContext)
            models += QuestionModel.modelsForQuestions(lessQuestions) as! [QuestionModel]
            if models.count > 0 {
                self.performSegueWithIdentifier("QuestionSheetViewController", sender: models)
            }
        }))
        
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
//    MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! QuestionCell
        let model = self.dataSource[indexPath.row]
        let q = model.question
        cell.numberLabel.text = q.number
        cell.titleLabel.text = q.text
        
        if q.learnStats != nil && q.learnStats.count > 0 {
            var set = q.learnStats as NSSet
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
    

}
