//
//  ExamResultViewController.swift
//  Fahrschule
//
//  Created on 29.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ExamResultViewController: UIViewController {
//    MARK: - Types
    struct MainStoryboard {
        struct SegueIdentifiers {
            static let showAllQuestions = "showAllQuestions"
            static let showErrorQuestions = "showErrorQuestions"
        }
    }
    
//    MARK: Public properties
    var managedObjectContext = SNAppDelegate.sharedDelegate().managedObjectContext!
    var questionModels: [QuestionModel]!
    var timeLeft: Int = 0
    var numQuestionsNotCorrectAnswered: Int = 0
    
    
//    MARK: Private properties
    private var examSheetDictionary: NSDictionary!
    private var maxPoints: Int = 0
    
    
//    MARK: Outlets
    @IBOutlet weak var succeedView: CircularCounterView!
    @IBOutlet weak var failedView: CircularCounterView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var faultsButton: UIButton!
    @IBOutlet weak var allQuestionsButton: UIButton!
    
    
    

    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("ExamSheet", ofType: "plist")
        examSheetDictionary = NSDictionary(contentsOfFile: path!)
        
        let key1 = "\(Settings.sharedSettings().licenseClass.rawValue)"
        let key2  = "\(Settings.sharedSettings().teachingType.rawValue)"
        maxPoints = examSheetDictionary.valueForKeyPath("\(key1).\(key2).MaxPoints")!.integerValue
        
        self.navigationItem.hidesBackButton = true
        
        // Statistic
        let examStat = ExamStatistic.insertNewStatistics(managedObjectContext, state: .FinishedExam)
        examStat.index = 0
        examStat.timeLeft = timeLeft
        
        
        NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationUpdateBadgeValue, object: nil)
        
        var points: Int = 0
        var mainGroupPoints: Int = 0
        var numFivePointsQuestionFalse: Int = 0
//        var mainGroupDict
//        var additionalGroupDict
//        var sortedGroupArray
        

        for model in self.questionModels {
            examStat.addStatisticsWithModel(model, inManagedObjectContext: managedObjectContext)
            if model.hasAnsweredCorrectly() == false {
                numQuestionsNotCorrectAnswered++
                points += model.question.points.integerValue
                if model.question.points.integerValue == 5 {
                    numFivePointsQuestionFalse++
                }
            }
        }
        
        SNAppDelegate.sharedDelegate().saveContext()
        
//        println("maxPoints \(maxPoints)\n")
//        
//        println("numFivePointsQuestionFalse \(numFivePointsQuestionFalse)\n")
//        
//        println("points \(points)\n")
        
        
        if points > maxPoints || (numFivePointsQuestionFalse == 2 && points == 10 && maxPoints == 10) {
            imageView.image = UIImage(named: "durchgefallen")
        }
        else if points == 0 {
            faultsButton.enabled = false
            
        }
        
        self.succeedView.title = NSLocalizedString("Richtig", comment: "")
        self.failedView.title = NSLocalizedString("Falsch", comment: "");
        
        self.failedView.countLabel.text = "\(self.numQuestionsNotCorrectAnswered)"
        self.succeedView.countLabel.text = "\(self.questionModels.count - numQuestionsNotCorrectAnswered)"
        
        self.titleLabel.text = String.localizedStringWithFormat(NSLocalizedString("%d Punkte", comment: ""), points)
        
        if points == 0 {
            self.subtitleLabel.text = NSLocalizedString("Fehlerlos! Hervorragend!", comment: "");
        }
        else if (points <= self.maxPoints || (numFivePointsQuestionFalse != 2 && points == 10 && self.maxPoints == 10)) {
            self.subtitleLabel.text = NSLocalizedString("Gratulation, bestanden!", comment: "");
        }
        else if ((points > self.maxPoints && points <= 20) || (numFivePointsQuestionFalse == 2 && points == 10 && self.maxPoints == 10)) {
            self.subtitleLabel.text = NSLocalizedString("Nicht schlecht, dranbleiben!", comment: "");
        }
        else if (points > 20 && points <= 60) {
            self.subtitleLabel.text = NSLocalizedString("Naja - üben, üben, üben!", comment: "");
        }
        else {
            self.subtitleLabel.text = NSLocalizedString("Ohje! Es gibt noch viel zu lernen.", comment: "");
        }
        
        
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = true
    }

//    MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get QuestionSheetController from stack
        let detailController = self.navigationController?.viewControllers.first as! QuestionSheetViewController
        
        let qsvc = segue.destinationViewController as! QuestionSheetViewController
        qsvc.solutionIsShown = true
        if segue.identifier == MainStoryboard.SegueIdentifiers.showAllQuestions {
            qsvc.questionModels = self.questionModels
        } else {
            var arr = [QuestionModel]()
            for model in self.questionModels {
                if model.hasAnsweredCorrectly() == false {
                    arr.append(model)
                }
            }
            qsvc.questionModels = arr
        }
        
        
        qsvc.currentIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        qsvc.currentIndex = 0
        
        
        // Get QuestionsTable Controller
        let masterController = detailController.masterViewController
        qsvc.masterViewController = masterController
        masterController?.dataSource = qsvc.questionModels
        if self.questionModels.count != masterController?.dataSource.count {
            masterController?.tableView.reloadData()
        }
        masterController?.questionSheetType = .History
       
        
        
        
    }
    
//    MARK: - Outlets functions
    @IBAction func didTapButtonClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func didTapButtonRetry(sender: AnyObject) {
        
        // Get QuestionSheetController from stack
        let detailController = self.navigationController?.viewControllers.first as! QuestionSheetViewController

        // Delete answered questions
        let models = detailController.questionModels
        for model in models {
            model.givenAnswers = nil
            model.hasSolutionBeenShown = false
        }
        
        // Get QuestionsTable Controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let masterController = detailController.masterViewController
            masterController?.questionSheetType = .Exam
            masterController?.dataSource = models
            masterController?.tableView.reloadData()
        }
        
        detailController.questionModels = models
        detailController.questionSheetType = .Exam
        detailController.currentIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        detailController.currentIndex = 0
        detailController.collectionView?.reloadData()
        detailController.timeLeft = 60 * 60
        detailController.startTimer()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        
    }
    
}
