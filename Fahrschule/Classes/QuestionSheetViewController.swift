//
//  QuestionSheetViewController.swift
//  Fahrschule
//
//  Created on 15.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit




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
    var currentIndexPath: NSIndexPath!
    var questionModels: [QuestionModel]!
    var questionSheetType: QuestionSheetType = .Learning
    
    var masterViewController: QuestionsTableViewController?
    var masterNavigationController: UINavigationController?
    var detailNavigationController: UINavigationController?
    
    // Timer
    private var examTimer: NSTimer?
    var timeLeft: Int = 60 * 60
    
    
    private var tapRecoginezer: UITapGestureRecognizer!
    
    
    var solutionIsShown: Bool = false
    
//    MARK: Outlets
    @IBOutlet weak var prevBarButton: UIBarButtonItem!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var titleBarButton: UIBarButtonItem!
    @IBOutlet var solutionButton: UIBarButtonItem!
    
    @IBOutlet var interruptButton: UIBarButtonItem!
    @IBOutlet var submitButton: UIBarButtonItem!
    
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
        configureView()

//         Register cell classes
        let nameSpaceClassName = NSStringFromClass(InquirerCollectionCell.self)
        let className = nameSpaceClassName.componentsSeparatedByString(".").last! as String
        self.collectionView!.registerNib(UINib(nibName: className, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        
        
        
        self.tapRecoginezer = UITapGestureRecognizer(target: self, action: Selector("showFullscreenImage:"))
        
//        Navigation bar
        var barButtonTitle = ""
        if self.questionSheetType == .Exam && !self.solutionIsShown {
            
            startTimer()
            self.timerLabel.text = timeLeftString()
            
            self.navigationItem.leftBarButtonItem = self.interruptButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let flowLayout = self.collectionView?.collectionViewLayout
        flowLayout?.invalidateLayout()
        self.navigationController?.toolbarHidden = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.currentIndexPath != nil {
            showQuestionAtIndexPath(self.currentIndexPath)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationDidSelectQuestion, object: self.currentIndexPath)
        
    }
    
//    MARK: - Public functions
    func showQuestionAtIndexPath(indexPath: NSIndexPath) {
        self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
        self.configureView()
    }
    
    private func scrollToIndexPath(indexPath: NSIndexPath) {
        let count: CGFloat = CGFloat(indexPath.item)
        let width: CGFloat = CGRectGetWidth(self.collectionView!.bounds)
        let offsetX =  count * width // CGFloat(indexPath.item)*CGRectGetWidth(self.collectionView?.bounds)
        self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        let delay = 0.25 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) { _ in
            self.currentIndex = Int(round(self.collectionView!.contentOffset.x / CGRectGetWidth(self.collectionView!.bounds)))
            let indexPath = NSIndexPath(forRow: self.currentIndex, inSection: 0)
            if self.currentIndexPath != nil {
                if indexPath.compare(self.currentIndexPath) != .OrderedSame {
                    self.currentIndexPath = indexPath
                    NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationDidSelectQuestion, object: indexPath)
                }
            } else {
                self.currentIndexPath = indexPath
                NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationDidSelectQuestion, object: indexPath)
            }
            
            self.configureView()
        }
        
    }
    
    
//    MARK: - Private functions
    private func configureView() {
        // NavigationItem.Title
        
        self.currentIndex = Int(round(self.collectionView!.contentOffset.x / CGRectGetWidth(self.collectionView!.bounds)))
        
        let model: QuestionModel = self.questionModels[self.currentIndex]
        var title = "\(self.currentIndex + 1)/\(self.questionModels.count) |  \(model.question.points) Pkt."
        if model.question.number.hasSuffix("-M") {
            title += " | M"
        }
        self.navigationItem.title = title
        
        // Next & Prev buttons
        self.prevBarButton.enabled = !(self.currentIndex == 0)
        self.nextBarButton.enabled = (self.currentIndex + 1 < self.questionModels.count)
        
        // Solution button
        if let btn = self.solutionButton {
            btn.enabled = !model.hasSolutionBeenShown
        }
        
        // Remove 'Solution' or add 'Abgeben' button
        if (self.solutionIsShown) {
            self.navigationItem.leftBarButtonItem = nil
            self.solutionButton.enabled = true
            var toolbarItems = self.toolbarItems as! [UIBarButtonItem]
            if let idx = find(toolbarItems, self.solutionButton) {
                toolbarItems.removeAtIndex(idx)
                self.toolbarItems = toolbarItems
            }
        }
        
        
        // Add Submit button
        if self.questionSheetType == .Exam {
            var toolbarItems = self.toolbarItems as! [UIBarButtonItem]
            if contains(toolbarItems, self.submitButton) == false {
                toolbarItems.insert(self.submitButton, atIndex: 2)
            }
            
            if contains(toolbarItems, self.solutionButton) {
                let idx = find(toolbarItems, self.solutionButton)
                toolbarItems.removeAtIndex(idx!)
            }
            
            self.toolbarItems = toolbarItems
        }
        
        
    }
    
    
    
    func showFullscreenImage(recognizer: UIGestureRecognizer) {
        println("\(NSStringFromClass(QuestionSheetViewController.self)) \(__FUNCTION__)")
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
        return self.timeLeft <= 60 ? "\(self.timeLeft)" : "\(Int(left)) min";
    }
    
    func handInExamAndShowResult() {
        self.examTimer?.invalidate()
        self.examTimer = nil
        self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showExamResults, sender: self)
    }
    
    func startTimer() {
        println("QuestionSheetViewController : \(__FUNCTION__)")
        if self.examTimer == nil {
            self.examTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("examTimeLeft:"), userInfo: nil, repeats: true)
            println("started")
        }
    }
    
    func stopTimer() {
        println("QuestionSheetViewController : \(__FUNCTION__)")
        
        if self.examTimer != nil {
            println("stoped")
            self.examTimer?.invalidate()
            self.examTimer = nil
        }
    }

    func numberOfAnsweredQuestions()->Int {
        var qty: Int = 0;
        for model in self.questionModels {
            if model.isAnAnswerGiven() {
                qty++;
            }
        }
        return qty
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Check Timer
        stopTimer()
        
        if segue.destinationViewController is LearningResultViewController || segue.destinationViewController is ExamResultViewController {

            if let resultsVC = segue.destinationViewController as? LearningResultViewController {
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
                
                // Get QuestionsTable Controller
                masterViewController?.dataSource = mutableArray
                masterViewController?.tableView.reloadData()
                masterViewController?.questionSheetType = QuestionSheetType.Learning

                
                resultsVC.managedObjectContext = self.managedObjectContext
                resultsVC.numQuestionsNotCorrectAnswered = numQuestionsNotCorrectAnswered
                resultsVC.questionModels = mutableArray
                
                
            }
            else if let examResultVC = segue.destinationViewController as? ExamResultViewController {
                masterViewController?.questionSheetType = QuestionSheetType.History
                examResultVC.managedObjectContext = self.managedObjectContext
                examResultVC.questionModels = self.questionModels
                examResultVC.timeLeft = self.timeLeft
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
    
    func didTapButtonFavorites(sender: UIButton) {
        sender.selected = !sender.selected
        let center = self.collectionView!.convertPoint(sender.center, fromView: sender.superview) as CGPoint
        let indexPath = self.collectionView!.indexPathForItemAtPoint(center)
        let qModel: QuestionModel = self.questionModels[self.currentIndex]
        qModel.question.setTagged(sender.selected, inManagedObjectContext: self.managedObjectContext)
        NSNotificationCenter.defaultCenter().postNotificationName("tagQuestion", object: nil)
        
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
    
    @IBAction func didTapButtonInterrupt(sender: AnyObject) {
        
        if self.questionSheetType == .Exam && !self.solutionIsShown {
            
            // Number of given answers
            var numAnsweredQuestions = numberOfAnsweredQuestions()
            
            
            //  No answers have been given
            if numAnsweredQuestions == 0 {
                self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
            } else {
                
                // Show alert
                let title = NSLocalizedString("Unterbrechen", comment: "")
                let msg = NSLocalizedString("Möchtest du die Prüfung wirklich unterbrechen?", comment: "")
                let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
                let yesBtn = NSLocalizedString("Ja",comment: "")
                let noBtn = NSLocalizedString("Nein", comment: "")
                
                
                // 'NO' action
                alertController.addAction(UIAlertAction(title: noBtn, style: .Cancel, handler: nil))
                
                // 'YES' action
                alertController.addAction(UIAlertAction(title: yesBtn, style: UIAlertActionStyle.Default, handler: { _ in
                    // Stop timer
                    self.stopTimer()
                    
                    // Caluclate statistic
                    let examStat = ExamStatistic.insertNewStatistics(self.managedObjectContext, state: .CanceledExam)
                    examStat.index = self.currentIndex
                    examStat.timeLeft = self.timeLeft
                    
                    for model in self.questionModels {
                        examStat.addStatisticsWithModel(model, inManagedObjectContext: self.managedObjectContext)
                    }
                    
                    // Store data into database
                    SNAppDelegate.sharedDelegate().saveContext()
                    
                    // Dismiss controller & update badge number
                    self.dismissViewControllerAnimated(true, completion: { _ in
                        NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationUpdateBadgeValue, object: nil)
                    })

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
    
    @IBAction func didTapButtonSubmit(sender: AnyObject) {
        // Number of given answers
        var numAnsweredQuestions = numberOfAnsweredQuestions()
        
        let answersToPass = self.questionModels.count - numAnsweredQuestions
        if answersToPass > 0 {

            let title = NSLocalizedString("Abgeben", comment: "")
            let msg = String.localizedStringWithFormat(NSLocalizedString("Du hast %d Fragen noch nicht beantwortet. Möchtest du trotzdem abgeben?", comment: ""), answersToPass)
            let yesBtn = NSLocalizedString("Ja",comment: "")
            let noBtn = NSLocalizedString("Nein", comment: "")
            
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)

            // 'NO' action
            alertController.addAction(UIAlertAction(title: noBtn, style: .Cancel, handler: nil))
            
            // 'YES' action
            alertController.addAction(UIAlertAction(title: yesBtn, style: .Default, handler: { _ in
                self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showExamResults, sender: self)
            }))

            self.presentViewController(alertController, animated: true, completion: nil)

        } else {
            self.performSegueWithIdentifier(MainStoryboard.SegueIdentifiers.showExamResults, sender: self)
        }
    }
    
    
    @IBAction func didTapCloseButton(sender: AnyObject) {
//        else if self.questionSheetType != .Exam && !Settings.sharedSettings().solutionMode {
        
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
            
//        }
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
        self.currentIndexPath = NSIndexPath(forItem: self.currentIndex, inSection: 0)
        NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationDidSelectQuestion, object: self.currentIndexPath)
    }
    
    
    
    
}
