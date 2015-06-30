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
            static let showCatalogPhone = "showCatalogList"
            static let showCatalogPad = "showCatalogListPad"
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
        
        var points: Int = 0
        var mainGroupPoints: Int = 0
        var numFivePointsQuestionFalse: Int = 0
//        var mainGroupDict
//        var additionalGroupDict
//        var sortedGroupArray

        for model in self.questionModels {
            examStat.addStatisticsWithModel(model, inManagedObjectContext: managedObjectContext)
            if model.hasAnsweredCorrectly() {
                points += model.question.points.integerValue
                if model.question.points.integerValue == 5 {
                    numFivePointsQuestionFalse++
                }
            }
        }
        
        SNAppDelegate.sharedDelegate().saveContext()
        
        println("maxPoints \(maxPoints)\n")
        
        println("numFivePointsQuestionFalse \(numFivePointsQuestionFalse)\n")
        
        println("points \(points)\n")
        
        
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
//    MARK: - Outlets functions
    @IBAction func didTapButtonClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func didTapButtonRetry(sender: AnyObject) {
        
    }
    
    @IBAction func didTapButtonAllQuestions(sender: AnyObject) {
    }
    
    @IBAction func didTapButtonShowErrors(sender: AnyObject) {
    }
    
}
