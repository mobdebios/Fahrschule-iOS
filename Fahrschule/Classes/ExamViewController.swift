//
//  ExamViewController.swift
//  Fahrschule
//
//  Created on 25.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ExamViewController: UIViewController {
//    MARK: - Types
    struct MainStoryboard {
        struct SegueIdentifiers {
            static let StartExam = "StartExam"
        }
    }
//    MARK: Properties
    var managedObjectContext = SNAppDelegate.sharedDelegate().managedObjectContext!
    var localObservers = [AnyObject]()

//    MARK: - Initialization & Delocation
    deinit {
        unregisterObservers()
    }
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        regisgerObservers()
        updateBadgeNumber()
    }

    
//    MARK: - Observers
    func regisgerObservers() {
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        localObservers.append(center.addObserverForName(SettingsNotificationUpdateBadgeValue, object: nil, queue: queue, usingBlock: { [weak self] _ in
            self?.updateBadgeNumber()
        }))
                
    }
    
    func unregisterObservers() {
        let center = NSNotificationCenter.defaultCenter()
        for observer in self.localObservers {
            center.removeObserver(observer)
        }
    }
    
//    Private functions
    private func updateBadgeNumber() {
        var badgerValue: String? = nil
        if ExamStatistic.statisticsInManagedObjectContext(self.managedObjectContext, fetchLimit: -1, state: .CanceledExam).count > 0 {
            badgerValue = "1"
        }
        self.navigationController!.tabBarItem.badgeValue = badgerValue
    }
    
    

//    MARK: - Navigation
    @IBAction func exitToExamViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let splitController = segue.destinationViewController as? UISplitViewController {
            let navigationController = splitController.viewControllers.first as? UINavigationController
            let masterController = navigationController?.topViewController as! QuestionsTableViewController
            
            let secondaryNavigationController = splitController.viewControllers.last as! UINavigationController
            let detailController = secondaryNavigationController.topViewController as! QuestionSheetViewController
            
            masterController.detailNavigationController = secondaryNavigationController
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                detailController.masterViewController = masterController
            }
            
            // Generate questions
            let models: [QuestionModel]
            if let examStat = ExamStatistic.statisticsInManagedObjectContext(managedObjectContext, fetchLimit: -1, state: .CanceledExam).last as? ExamStatistic {
                masterController.currentIndexPath = NSIndexPath(forRow: examStat.index.integerValue, inSection: 0)
                detailController.timeLeft = examStat.timeLeft.integerValue
                models = examStat.questionModelsForExam() as! [QuestionModel]
            } else {
                let questions = Question.examQuestionsInManagedObjectContext(managedObjectContext)
                models = QuestionModel.modelsForQuestions(questions) as! [QuestionModel]
                for model in models {
                    model.givenAnswers = nil
                    model.hasSolutionBeenShown = false
                }
                masterController.currentIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            }
            
            detailController.currentIndexPath = masterController.currentIndexPath!
            
            masterController.title = NSLocalizedString("Fragenübersicht", comment: "")
            masterController.navigationItem.rightBarButtonItem = nil
            masterController.managedObjectContext = managedObjectContext

            masterController.dataSource = models
            masterController.questionSheetType = .Exam
            
            
            detailController.managedObjectContext = self.managedObjectContext;
            detailController.questionModels = models
            
            detailController.questionSheetType = .Exam
            detailController.title = NSLocalizedString("Prüfung", comment: "")
            splitController.delegate = masterController

        }
    }
    
//    MARK: - Outlet functions
    @IBAction func didTapButtonStart(sender: AnyObject) {
        
        if let examStat = ExamStatistic.statisticsInManagedObjectContext(managedObjectContext, fetchLimit: -1, state: .CanceledExam).last as? ExamStatistic {
            let msg = NSLocalizedString("Möchtest du die letzte Prüfung fortsetzen?", comment: "")
            let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .Alert)
           
            // Cancel
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Abbrechen", comment: ""), style: .Cancel, handler: nil))
            
            // Continue old
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Prüfung fortsetzen", comment: ""), style: .Default, handler: { _ in
                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.StartExam, sender: sender)
            }))
            
            // Start new
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Neue Prüfung starten", comment: ""), style: .Default, handler: { _ in
                // Delete previous exam stat
                examStat.deleteExamInManagedObjectContext(self.managedObjectContext)
                self.updateBadgeNumber()
                
                // show exam sheet
                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.StartExam, sender: sender)
            }))
            
            
            // Show alert controller
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // show exam sheet
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.StartExam, sender: sender)
        }
    }
    
    
    
    

}
