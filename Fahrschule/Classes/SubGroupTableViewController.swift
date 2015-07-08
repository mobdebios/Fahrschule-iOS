//
//  SubGroupTableViewController.swift
//  Fahrschule
//
//  Created on 19.06.15.
//  Copyright (c) 2015 RE'FLEKT. All rights reserved.
//

import UIKit

class SubGroupTableViewController: UITableViewController {
    
//    MARK: - Types
    struct MainStoryboard {
        
        struct TableViewCellIdentifiers {
            static let subgroupCellIdentifier = "Cell"
        }
        
        
        struct SegueIdentifiers {
            static let showQuestionnaire = "QuestionSheetViewController"
        }
        
        struct Restoration {
            static let managedObjectID = "managedObjectID"
        }
        
        struct ViewControllerIdentifier {
            static let Questions = "QuestionsTableViewController"
        }
    }
    
//    MARK: Properties
    var masterNavigationController: UINavigationController?
    var detailNavigationController: UINavigationController?
    var managedObjectContext: NSManagedObjectContext!
    var dataSource: [SubGroup]!
    var mainGroup: MainGroup! {
        didSet {
            self.dataSource = SubGroup.subGroupsInRelationsTo(self.mainGroup, inManagedObjectContext: self.managedObjectContext) as! [SubGroup]
        }
    }
    
    
    
//    MARK: - State Save and Preservation
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        coder.encodeObject(self.mainGroup.objectID.URIRepresentation(), forKey: MainStoryboard.Restoration.managedObjectID)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        //        Restore Subgroup
        self.managedObjectContext = SNAppDelegate.sharedDelegate().managedObjectContext
        
        let objURI = coder.decodeObjectForKey(MainStoryboard.Restoration.managedObjectID) as! NSURL
        let objID: NSManagedObjectID = self.managedObjectContext.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(objURI)!
        self.mainGroup = self.managedObjectContext.objectWithID(objID) as! MainGroup
        
        
        
    }
    
    override func applicationFinishedRestoringState() {
        self.title = self.mainGroup.name
    }

//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table Settings
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.estimatedRowHeight = 44.0
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Zurück", comment: ""), style: .Plain, target: nil, action: nil)
        
        
        #if FAHRSCHULE_LITE
//            [self showbannerFullversionAnimated];
        #endif

    }


//    MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? QuestionsTableViewController {
            let indexPath: NSIndexPath = self.tableView!.indexPathForSelectedRow()!
            vc.managedObjectContext = self.managedObjectContext
            vc.subGroup = self.dataSource[indexPath.row]
        }
        else if let models = sender as? [QuestionModel] {
            if let navController = segue.destinationViewController as? UINavigationController {
                if let qsvc = navController.topViewController as? QuestionSheetViewController {
                    qsvc.managedObjectContext = self.managedObjectContext
                    for model in models {
                        model.givenAnswers = nil
                        model.hasSolutionBeenShown = false
                    }
                    qsvc.questionModels = models
                                        
                }
            }
        }
    }
    
//    MARK: - Outlet functions
    @IBAction func didTapButtonQuery(sender: UIBarButtonItem) {
        let title = NSLocalizedString("Was soll abgefragt werden?", comment: "");
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        
        // Cancel
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Abbrechen", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
        
        // All topics
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Themenbereiche", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.mainGroup, inManagedObjectContext: self.managedObjectContext) as! [Question]
            self.openQuestionSheetController(questions)
        }))
        
        
        // All incorrect answers
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle falsch Beantworteten", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.mainGroup, state: StatisticState.FaultyAnswered, inManagedObjectContext: self.managedObjectContext) as! [Question]
            self.openQuestionSheetController(questions)
        }))
        
        // All unanswered questions
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Alle Unbeantworteten", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            let questions = Question.questionsInRelationsTo(self.mainGroup, state: StatisticState.StateLess, inManagedObjectContext: self.managedObjectContext) as! [Question]
            self.openQuestionSheetController(questions)
        }))
        
        // False & Unanswered questions
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Falsch & Unbeantwortete", comment: ""), style: .Default, handler: { (alertAction) -> Void in
            var questions = Question.questionsInRelationsTo(self.mainGroup, state: StatisticState.FaultyAnswered, inManagedObjectContext: self.managedObjectContext) as! [Question]
            questions += Question.questionsInRelationsTo(self.mainGroup, state: StatisticState.StateLess, inManagedObjectContext: self.managedObjectContext) as! [Question]
            self.openQuestionSheetController(questions)
            
        }))
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
//    MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.subgroupCellIdentifier, forIndexPath: indexPath) as! SubgroupCell
        let subGroup = self.dataSource[indexPath.row]
        cell.numberLabel.text = subGroup.number
        cell.titleLabel.text =  subGroup.name
        return cell
    }
    
//    MARK: - Table View delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let subGroup = dataSource[indexPath.row]
        let questionsController = storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.ViewControllerIdentifier.Questions) as! QuestionsTableViewController
        questionsController.managedObjectContext = managedObjectContext
        questionsController.subGroup = subGroup
        
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            if navigationController == masterNavigationController {
                // Update detail controller
                
                
            } else {
                // Update master controller
                if masterNavigationController?.viewControllers.count > 2 {
                    masterNavigationController?.popToViewController(masterNavigationController!.viewControllers[2] as! UIViewController, animated: false)
                }
                
                let subgroupController = storyboard?.instantiateViewControllerWithIdentifier("SubGroupTableViewController") as! SubGroupTableViewController
                subgroupController.managedObjectContext = managedObjectContext
                subgroupController.dataSource = dataSource
                subgroupController.title = self.title
                subgroupController.mainGroup = mainGroup
            
                masterNavigationController?.pushViewController(subgroupController, animated: true)
                
                
                // Update detail controller
                questionsController.navigationItem.hidesBackButton = true
                navigationController?.pushViewController(questionsController, animated: true)
            }
            
        case .Phone:
            navigationController?.pushViewController(questionsController, animated: true)
        default: return
        }
        
        
//        vc.managedObjectContext = self.managedObjectContext
//        vc.subGroup = self.dataSource[indexPath.row]
    }
    
//    MARK: - Private functions
    private func openQuestionSheetController(questions: [Question]) {
        
//        if let models = QuestionModel.modelsForQuestions(questions) as? [QuestionModel] {
//            if models.count > 0 {
//                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showQuestionnaire, sender: models)
//            }
//        }
    }
    

}
