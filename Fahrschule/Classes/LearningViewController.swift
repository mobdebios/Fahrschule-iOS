//
//  LearningViewController.swift
//  Fahrschule
//
//  Created on 24.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class LearningViewController: UIViewController {

//    MARK: - Types
    struct MainStoryboard {
        struct ViewControllerIndentifier {
            static let LearningViewController = "LearningViewController"
        }
        
        struct SegueIdentifiers {
            static let showCatalogPhone = "showCatalogList"
            static let showCatalogPad = "showCatalogListPad"
        }
        
        struct Restoration {
            static let managedObjectID = "managedObjectID"
        }
    }
    
//    MARK: Properties
    var managedObjectContext = SNAppDelegate.sharedDelegate().managedObjectContext!
    
//    MARK: Outlets
    @IBOutlet weak var succeedView: CircularCounterView!
    @IBOutlet weak var failedView: CircularCounterView!
    @IBOutlet weak var remainingView: CircularCounterView!
    @IBOutlet weak var chartView: CircularChartView!
    @IBOutlet weak var questionnaireButton: UIButton!
    
    
//    MARK: - Initialization & Delocation
    deinit {
        unregisterObservers()
    }

//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.succeedView.title = NSLocalizedString("Richtig", comment: "");
        self.failedView.title = NSLocalizedString("Falsch", comment: "");
        self.remainingView.title = NSLocalizedString("Verbleibend", comment: "");
        self.chartView.subtitle = NSLocalizedString("beantwortet", comment: "");
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if self.parentViewController?.parentViewController is UISplitViewController {
                self.questionnaireButton.hidden = true
            }
        }
        
        registerObservers()
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
//    MARK: - Observers
    func registerObservers() {
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: SettingsLicenseClassKey, options: .New, context: nil)
    }
    
    func unregisterObservers() {
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: SettingsLicenseClassKey)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
        case SettingsLicenseClassKey:
            configureView()
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
    }

//    MARK: - Private functions
    func configureView() {
        
        // Get number of correct answered questions
        var correctAnswer: UInt = LearningStatistic.countStatisticsInRelationsTo(nil, inManagedObjectContext: managedObjectContext, showState: .CorrectAnswered) as UInt
        succeedView?.countLabel.text = "\(correctAnswer)"
        succeedView?.setNeedsLayout()
        
        // Get number of faulty answered questions
        let faultyAnswers = LearningStatistic.countStatisticsInRelationsTo(nil, inManagedObjectContext: managedObjectContext, showState: .FaultyAnswered)
        failedView?.countLabel.text = "\(faultyAnswers)"
        failedView?.setNeedsLayout()
        
        // Get number of remaining questions
        let totalAnswers = Question.countQuestionsInRelationsTo(nil, inManagedObjectContext: managedObjectContext)
        let remainingAnswers = totalAnswers - correctAnswer - faultyAnswers
        remainingView?.countLabel.text = "\(totalAnswers)"
        remainingView?.setNeedsLayout()

        // Adding values to circle chart
        chartView?.succeed = Int(correctAnswer)
        chartView?.failed = Int(faultyAnswers)
        chartView?.remaining = Int(remainingAnswers)
        
    }
    

//    MARK: - Navigation
    @IBAction func exitToLearningViewController(seque: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? QuestionCatalogTableViewController {
            vc.managedObjectContext = self.managedObjectContext
        } else {
            if let splitControler = segue.destinationViewController as? UISplitViewController {
                splitControler.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
                let masterNavController = splitControler.viewControllers.first as? UINavigationController
                let catalogsController = masterNavController?.topViewController as? QuestionCatalogTableViewController
                catalogsController?.managedObjectContext = self.managedObjectContext
                
                let learningController = self.storyboard?.instantiateViewControllerWithIdentifier(MainStoryboard.ViewControllerIndentifier.LearningViewController) as! LearningViewController
                learningController.managedObjectContext = self.managedObjectContext;
                let navController = UINavigationController(rootViewController: learningController)
                catalogsController?.detailNavigationController = navController
                learningController.questionnaireButton?.hidden = true
                splitControler.showDetailViewController(navController, sender: sender)
                
            }
        }
    }
    
//    MARK: - Outlet methods
    @IBAction func didTapButtonQuestionarie(sender: AnyObject) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showCatalogPhone, sender: sender)
        } else {
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showCatalogPad, sender: sender)
        }
    }
    
}
