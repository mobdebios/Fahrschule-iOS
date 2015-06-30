//
//  QuestionSheetViewController.swift
//  Fahrschule
//
//  Created on 15.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

enum QuestionSheetType: Int {
    case Learning
    case Exam
    case RetryExam
    case History
}


let reuseIdentifier = "Cell"

class QuestionSheetViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
//    MARK: - Types
    struct MainStoryboard {
        struct SegueIdentifiers {
            static let showTestResults = "LearningResultViewController"
            static let showExamResults = "showExamResults"
        }
    }
    
//    LearningResultViewController
    
//    MARK: Properties
    var managedObjectContext: NSManagedObjectContext!
    var currentIndex: Int = 0
    var currentIndexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    var questionModels: [QuestionModel]!
    var isOfficialLayout: Bool = true
    
    // Timer
    var examTimer: NSTimer?
    var timeLeft: Int = 60 * 60
    
    
    var tapRecoginezer: UITapGestureRecognizer!
    var questionSheetType: QuestionSheetType = .Learning
    
    
    var solutionIsShown: Bool = false
//    Old code
//    var isExam: Bool = false
    var retryExam: Bool = false
    
//    MARK: Outlets
    @IBOutlet weak var prevBarButton: UIBarButtonItem!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var titleBarButton: UIBarButtonItem!
    @IBOutlet weak var solutionButton: UIBarButtonItem!
    @IBOutlet var interruptButton: UIBarButtonItem!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    
    
//    MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

         self.clearsSelectionOnViewWillAppear = true
        
//        Flow Layout
        var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        self.collectionView?.pagingEnabled = true
        self.collectionView?.collectionViewLayout = flowLayout
        
//        Configure
        self.navigationController?.toolbarHidden = false

//         Register cell classes
        let nameSpaceClassName = NSStringFromClass(InquirerCollectionCell.self)
        let className = nameSpaceClassName.componentsSeparatedByString(".").last! as String
        self.collectionView!.registerNib(UINib(nibName: className, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

//         Remove 'Solution' or add 'Abgeben' button
        if (self.solutionIsShown) {
            self.navigationItem.leftBarButtonItem = nil
            self.solutionButton.enabled = true
            var toolbarItems = self.toolbarItems as! [UIBarButtonItem]
            if let idx = find(toolbarItems, self.solutionButton) {
                toolbarItems.removeAtIndex(idx)
                self.toolbarItems = toolbarItems
            }
        }
        
        self.tapRecoginezer = UITapGestureRecognizer(target: self, action: Selector("showFullscreenImage:"))
        
//        Navigation bar
        var barButtonTitle = ""
        if self.questionSheetType == .Exam && !self.solutionIsShown {
            self.navigationItem.leftBarButtonItem = self.interruptButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.configureView()
        let flowLayout = self.collectionView?.collectionViewLayout
        flowLayout?.invalidateLayout()
        
        self.navigationController?.toolbarHidden = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
//    MARK: - Public functions
    func showQuestionAtIndexPath(indexPath: NSIndexPath) {
        self.collectionView?.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
        self.configureView()
    }
    
    func examTimeLeft(sender: AnyObject) {
        self.timeLeft--
        
        if self.timeLeft % 60 == 0 || self.timeLeft <= 60 {
            if self.timeLeft == 0 {
                handInExamAndShowResult()
            }
            else if self.timeLeft < 60 {
                self.timerLabel.textColor = UIColor.redColor()
            }
            
            self.timerLabel.text = timeLeftString()
        }
    }
    
    func timeLeftString()->String {
        let left = ceil(Double(self.timeLeft) / 60.0)
        return self.timeLeft <= 60 ? "\(self.timeLeft)" : "\(Int(left))";
    }
    
    func handInExamAndShowResult() {
        
        self.examTimer?.invalidate()
        self.examTimer = nil
        self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showExamResults, sender: self)
    }

    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationViewController is LearningResultViewController || segue.destinationViewController is ExamResultViewController {
            
            var index = 0
            var numQuestionsNotCorrectAnswered = 0
            var mutableArray = [QuestionModel]()
            var questions = [Question]()
            
            for model in questionModels {
                if model.isAnAnswerGiven() {
                    let newModel = QuestionModel(question: model.question, atIndex: index++)
                    newModel.givenAnswers = model.givenAnswers
                    mutableArray.append(newModel)
                    questions.append(newModel.question)
                    
                    var arr = model.givenAnswers as [AnyObject]
                    if LearningStatistic.addStatistics(arr, forQuestion: model.question, inManagedObjectContext: self.managedObjectContext) == .FaultyAnswered {
                        numQuestionsNotCorrectAnswered++
                    }
                }
                
                model.givenAnswers = nil
                model.hasSolutionBeenShown = false
                
            }
            
            if let resultsVC = segue.destinationViewController as? LearningResultViewController {
                resultsVC.managedObjectContext = self.managedObjectContext
                resultsVC.numQuestionsNotCorrectAnswered = numQuestionsNotCorrectAnswered
                resultsVC.questionModels = mutableArray
                
                
            }
            else if let examResultVC = segue.destinationViewController as? ExamResultViewController {
                examResultVC.managedObjectContext = self.managedObjectContext
                examResultVC.numQuestionsNotCorrectAnswered = numQuestionsNotCorrectAnswered
                examResultVC.questionModels = mutableArray
            }
            
            SNAppDelegate.sharedDelegate().saveContext()
            
        }
        
    }
    
    // MARK: - Outlet Functions
    @IBAction func didTapButtonPrev(sender: AnyObject) {
        let idx = Int(round(self.collectionView!.contentOffset.x / CGRectGetWidth(self.collectionView!.bounds)))
        if idx > 0 {
            let indexPath = NSIndexPath(forItem: idx - 1, inSection: 0)
            self.scrollToIndexPath(indexPath)
        }
    }
    
    @IBAction func didTapButtonNext(sender: AnyObject) {
        let idx = Int(round(self.collectionView!.contentOffset.x / CGRectGetWidth(self.collectionView!.bounds)))
        if idx < self.questionModels.count - 1 {
            let indexPath = NSIndexPath(forItem: idx + 1, inSection: 0)
            self.scrollToIndexPath(indexPath)
        }
    }
    
    private func scrollToIndexPath(indexPath: NSIndexPath) {
        let count: CGFloat = CGFloat(indexPath.item)
        let width: CGFloat = CGRectGetWidth(self.collectionView!.bounds)
        let offsetX =  count * width // CGFloat(indexPath.item)*CGRectGetWidth(self.collectionView?.bounds)
        self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        let delay = 0.25 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            self.configureView()
        }
        
    }
    
    @IBAction func didTapButtonSolution(sender: UIBarButtonItem) {
//        sender.enabled = false
        let arr = self.collectionView!.indexPathsForVisibleItems()
        let indexPath = arr.first as! NSIndexPath
        let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! InquirerCollectionCell
        
        if cell.questionModel.isAnAnswerGiven() == true {
            var arr = cell.questionModel.givenAnswers as [AnyObject]
            LearningStatistic.addStatistics(arr, forQuestion: cell.questionModel.question, inManagedObjectContext: self.managedObjectContext)
        
        }
        
        self.solutionButton.enabled = false
        cell.questionModel.hasSolutionBeenShown = true
        cell.showSolutions()
        cell.tableView.allowsSelection = false

    }
    
    @IBAction func didTapButtonClose(sender: AnyObject) {
        
        if self.questionSheetType == .Exam && !self.solutionIsShown {
            
//            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showExamResults, sender: self)
//            return
            
            // Number of given answers
            var numAnsweredQuestions: Int = 0;
            for model in self.questionModels {
                
                if model.isAnAnswerGiven() {
                    numAnsweredQuestions++;
                }
            }
            
            // Stop timer
            self.examTimer?.invalidate()
            self.examTimer = nil
            
            //  No answers have been given
            if numAnsweredQuestions == 0 {
                self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
            } else {
                
                // Caluclate statistic
                let examStat = ExamStatistic.insertNewStatistics(self.managedObjectContext, state: .CanceledExam)
                examStat.index = self.currentIndex
                examStat.timeLeft = self.timeLeft
                
                for model in self.questionModels {
                    examStat.addStatisticsWithModel(model, inManagedObjectContext: self.managedObjectContext)
                }
                
                // Store data into database
                SNAppDelegate.sharedDelegate().saveContext()
                
                
                // Show alert
                let title = NSLocalizedString("Unterbrechen", comment: "")
                let msg = NSLocalizedString("Möchtest du die Prüfung wirklich unterbrechen?", comment: "")
                let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
                let yesBtn = NSLocalizedString("Ja",comment: "")
                let noBtn = NSLocalizedString("Nein", comment: "")
                
                alertController.addAction(UIAlertAction(title: noBtn, style: .Cancel, handler: nil))
                
                alertController.addAction(UIAlertAction(title: yesBtn, style: UIAlertActionStyle.Default, handler: { _ in
                    NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationUpdateBadgeValue, object: nil)
                    
                    let answersToPass = self.questionModels.count - numAnsweredQuestions
                    if answersToPass > 0 {
                        
                        let title = NSLocalizedString("Abgeben", comment: "")
                        let msg = String.localizedStringWithFormat(NSLocalizedString("Du hast %d Fragen noch nicht beantwortet. Möchtest du trotzdem abgeben?", comment: ""), answersToPass)
                        
                        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
                        
                        alertController.addAction(UIAlertAction(title: noBtn, style: .Cancel, handler: nil))
                        alertController.addAction(UIAlertAction(title: yesBtn, style: .Default, handler: { _ in
                            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showExamResults, sender: self)
                        }))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    } else {
                        self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showExamResults, sender: self)
                    }
                }))
                
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }

            
            
            
        }
        else if self.questionSheetType != .Exam && !Settings.sharedSettings().solutionMode {
            
            var givenAnswersCount = 0
            for qm in self.questionModels {
                if qm.isAnAnswerGiven() {
                    givenAnswersCount++
                }
            }
            
            if givenAnswersCount > 0 {
                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showTestResults, sender: self)
            } else {
                self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }

    }
    
    

    // MARK:  - Collection View datasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.questionModels.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! InquirerCollectionCell
        
        let model = self.questionModels[indexPath.item]
        if self.solutionIsShown {
            model.hasSolutionBeenShown = true
        }
        
        if model.questionType == .NumberQuestion {
            println("QuestionSheetViewController : \(__FUNCTION__)) NumberQuestion\n")
            println("model \(model)\n")
            println("model \(model.question)\n")

        }
        
        cell.questionModel = model
        if self.isIPAD() {
            var tapRecoginezer = UITapGestureRecognizer(target: self, action: Selector("showFullscreenImage:"))
            cell.imageView.addGestureRecognizer(tapRecoginezer)
        }
        
        cell.favoriteButton.selected = model.question.isQuestionTagged()
        cell.favoriteButton.addTarget(self, action: Selector("didTapButtonFavorites:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }

//    MARK: - UICollectionView delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds) - collectionView.contentInset.top - collectionView.contentInset.bottom)
    }
    
//    MARK: - Scroll View delegate
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.configureView()
    }
    
    // MARK: - Private functions
    private func configureView() {
//        NavigationItem.Title
        
        self.currentIndex = Int(round(self.collectionView!.contentOffset.x / CGRectGetWidth(self.collectionView!.bounds)))
        let indexPath = NSIndexPath(forRow: self.currentIndex, inSection: 0)
        if indexPath.compare(self.currentIndexPath) != .OrderedSame {
            self.currentIndexPath = indexPath
            NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationDidSelectQuestion, object: indexPath)
        }
        
        let model: QuestionModel = self.questionModels[self.currentIndex]
        var title = "\(self.currentIndex + 1)/\(self.questionModels.count) |  \(model.question.points) Pkt."
        if model.question.number.hasSuffix("-M") {
            title += " | M"
        }
        self.navigationItem.title = title
        
//        Next & Prev buttons
        self.prevBarButton.enabled = !(self.currentIndex == 0)
        self.nextBarButton.enabled = (self.currentIndex + 1 < self.questionModels.count)
        
//        Solution button
        if let btn = self.solutionButton {
            btn.enabled = !model.hasSolutionBeenShown
        }

    }
    
    func showFullscreenImage(recognizer: UIGestureRecognizer) {
        println("\(NSStringFromClass(QuestionSheetViewController.self)) \(__FUNCTION__)")
    }
    
    func didTapButtonFavorites(sender: UIButton) {
        sender.selected = !sender.selected
        let center = self.collectionView!.convertPoint(sender.center, fromView: sender.superview) as CGPoint
        let indexPath = self.collectionView!.indexPathForItemAtPoint(center)
        let qModel: QuestionModel = self.questionModels[self.currentIndex]
        qModel.question.setTagged(sender.selected, inManagedObjectContext: self.managedObjectContext)
        NSNotificationCenter.defaultCenter().postNotificationName("tagQuestion", object: nil)
        
    }
    
}
