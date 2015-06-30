//
//  LearningResultViewController.swift
//  Fahrschule
//
//  Created on 17.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class LearningResultViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var succeedView: CircularCounterView!
    @IBOutlet weak var failedView: CircularCounterView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var errorButton: UIButton!
    
    var numQuestionsNotCorrectAnswered: Int = 0
    
    
    var managedObjectContext: NSManagedObjectContext!
    var questionModels: [QuestionModel]!
    
//    MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.succeedView.title = NSLocalizedString("Richtig", comment: "")
        self.failedView.title = NSLocalizedString("Falsch", comment: "");
        
        self.failedView.countLabel.text = "\(self.numQuestionsNotCorrectAnswered)"
        self.succeedView.countLabel.text = "\(self.questionModels.count - numQuestionsNotCorrectAnswered)"
        
        if self.questionModels.count == 1 {
            self.titleLabel.text = NSLocalizedString("Du hast 1 Frage bearbeitet.", comment: "")
        } else {
            self.titleLabel.text = String.localizedStringWithFormat(NSLocalizedString("Du hast %d Fragen bearbeitet.", comment: ""), self.questionModels.count)
        }
        
        self.errorButton.enabled = self.numQuestionsNotCorrectAnswered > 0
        
/// TODO: iPad version
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = true
    }
    

//    MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let qsvc = segue.destinationViewController as? QuestionSheetViewController {
            
            var questionsModels = self.questionModels
            
            // Show only incorrect questions
            if let btn = sender as? UIButton {
                if btn == self.errorButton {
                    var models = [QuestionModel]()
                    var index = 0
                    for model in self.questionModels {
                        if !model.hasAnsweredCorrectly() {
                            let newModel = QuestionModel(question: model.question, atIndex: index++)
                            newModel.givenAnswers = model.givenAnswers
                            models.append(newModel)
                        }
                    }
                    questionModels = models
                }
            }
            
            
            qsvc.managedObjectContext = self.managedObjectContext
            qsvc.questionModels = questionModels
            qsvc.solutionIsShown = true
            qsvc.navigationItem.leftBarButtonItem = nil
            
        }
        
    }
    
//    MARK: - Outlet functions
    
    @IBAction func didTapButtonClose(sender: AnyObject) {
        #if FAHRSCHULE_LITE
            //        BuyFullVersionViewController *bfvvc = [[BuyFullVersionViewController alloc] initWithOfficialView:NO];
            //        [self.navigationController pushViewController:bfvvc animated:YES];
        #else
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
            }
            
        #endif
        
    }

}
