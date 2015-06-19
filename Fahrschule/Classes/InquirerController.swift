//
//  InquirerController.swift
//  Fahrschule
//
//  Created on 15.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class InquirerController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    var managedObjectContext: NSManagedObjectContext?
    var currentIndexPath: NSIndexPath!
    var questionModels: [QuestionModel]!
    var isOfficialLayout: Bool = true
    var tapRecoginezer: UITapGestureRecognizer!
    
//    @property (nonatomic, readonly) Settings *userSettings;
    
//    Old code
    var isExam: Bool = false
    var solutionIsShown: Bool = false
    var retryExam: Bool = false
    
//    Outlets
    @IBOutlet weak var prevBarButton: UIBarButtonItem!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var titleBarButton: UIBarButtonItem!
    @IBOutlet weak var solutionButton: UIBarButtonItem!
    
//    
    var currentIndex: Int = 0
    
//    MARK: View Life cycle
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
        if self.isExam && !self.solutionIsShown {
            barButtonTitle = NSLocalizedString("Unterbrechen", comment:"")
        } else {
            barButtonTitle = NSLocalizedString("Schließen", comment:"")
        }
        
        if self.isIPAD() {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.currentIndexPath != nil {
            self.collectionView!.scrollToItemAtIndexPath(self.currentIndexPath, atScrollPosition: .CenteredHorizontally, animated: false)
        }
        
        self.configureView()
        
    }
    
    //  MARK: - Rotation handling methods
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {

        // Fade the collectionView out
        self.collectionView?.alpha = 0.0
        
        // Suppress the layout errors by invalidating the layout
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        // Calculate the index of the item that the collectionView is currently displaying
        let currentOffset = self.collectionView!.contentOffset
        self.currentIndex = Int(round(currentOffset.x / CGRectGetWidth(self.collectionView!.frame)))
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        // Force realignment of cell being displayed
        var offset =  CGFloat(self.currentIndex) * CGRectGetWidth(self.collectionView!.frame)
        self.collectionView?.contentOffset = CGPointMake(offset, 0)
        
        // Fade the collectionView back in
        UIView.animateWithDuration(0.125, animations: { () -> Void in
            self.collectionView?.alpha = 1.0
        })
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let resultsVC = segue.destinationViewController as? LearningResultViewController {
            resultsVC.managedObjectContext = self.managedObjectContext
            
            var index = 0
            var numQuestionsNotCorrectAnswered = 0
            var mutableArray = [QuestionModel]()
            var questions = [Question]()
            
            for qm in questionModels {
                if qm.isAnAnswerGiven() {
                    let newModel = QuestionModel(question: qm.question, atIndex: index++)
                    newModel.givenAnswers = qm.givenAnswers
                    mutableArray.append(newModel)
                    questions.append(newModel.question)
                    
                    var arr = qm.givenAnswers as [AnyObject]
                    if LearningStatistic.addStatistics(arr, forQuestion: qm.question, inManagedObjectContext: self.managedObjectContext) == .FaultyAnswered {
                        numQuestionsNotCorrectAnswered++
                    }
                }
                
                qm.givenAnswers = nil
                qm.hasSolutionBeenShown = false
                
            }
            
            resultsVC.numQuestionsNotCorrectAnswered = numQuestionsNotCorrectAnswered
            resultsVC.questionModels = mutableArray
            
            SNAppDelegate.sharedDelegate().saveContext()
            
        }
    }
    
    // MARK: - Outlet Functions
    
    @IBAction func didTapButtonSubmit(sender: AnyObject) {
        var numAnsweredQuestions = 0
        for model: QuestionModel in self.questionModels {
            numAnsweredQuestions++
        }
        
        var actionSheetMessage = ""
        if numAnsweredQuestions != self.questionModels.count {
            actionSheetMessage = NSLocalizedString("Du hast \(self.questionModels.count - numAnsweredQuestions) Fragen noch nicht beantwortet. Möchtest du trotzdem abgeben?", comment: "")
        } else {
            actionSheetMessage = NSLocalizedString("Möchtest du die Prüfung jetzt abgeben?", comment: "")
        }
        
        var alertController = UIAlertController(title: actionSheetMessage, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        
/*
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:actionSheetMessage delegate:self
        cancelButtonTitle:NSLocalizedString(@"Nein", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ja", @""), nil];
        [action setTag:kHandInExam];
        action.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [action showInView:self.view];
*/
    
    }
    
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
        
        
        /*
        
        
        if ([self.questionModel.question whatType] == kChoiceQuestion) {
        NSArray *cells = [self.answersTableView visibleCells];
        for (int i = 0; i < [cells count]; i++) {
        AnswerTableViewCell *cell = (AnswerTableViewCell *)[cells objectAtIndex:i];
        
        if ([cell isCorrect] || cell.tag == 1) {
        [cell setAnswerIndicator];
        }
        }
        
        self.answersTableView.allowsSelection = NO;
        }
        else {
        Answer *answer = [[self.questionModel.question.choices allObjects] objectAtIndex:0];
        
        if ([self.questionModel.question answerState:self.questionModel.givenAnswers] == kFaultyAnswered) {
        self.numberImageView.image = [UIImage imageNamed:@"icon_falsch.png"];
        }
        else {
        self.numberImageView.image = [UIImage imageNamed:@"icon_richtig.png"];
        }
        
        UITextField *numberTextField = [self.numberTextFields objectAtIndex:0];
        self.numberLabel.hidden = NO;
        numberTextField.enabled = NO;
        
        if ([self.questionModel.givenAnswers count] > 0 && [[self.questionModel.givenAnswers objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
        NSNumber *value = [self.questionModel.givenAnswers objectAtIndex:0];
        numberTextField.text = [value intValue] == -1 ? @"" : [value stringValue];
        }
        
        if (![[self.numberTextFields objectAtIndex:1] isHidden]) {
        NSArray *correctNumbers = [[answer.correctNumber stringValue] componentsSeparatedByString:@"."];
        self.numberLabel.text = [[answer.text stringByReplacingOccurrencesOfString:@"X" withString:[correctNumbers objectAtIndex:0]]
        stringByReplacingOccurrencesOfString:@"Y" withString:[correctNumbers objectAtIndex:1]];
        
        if ([[self.questionModel.givenAnswers objectAtIndex:1] isKindOfClass:[NSNumber class]]) {
        UITextField *secondNumberTextField = [self.numberTextFields objectAtIndex:1];
        NSNumber *value = [self.questionModel.givenAnswers objectAtIndex:1];
        secondNumberTextField.text = [value intValue] == -1 ? @"" : [value stringValue];
        secondNumberTextField.enabled = NO;
        }
        }
        else {
        self.numberLabel.text = [answer.text stringByReplacingOccurrencesOfString:@"X" withString:[answer.correctNumber stringValue]];
        }
        
        CGRect drawingBounds = [self.numberLabel textRectForBounds:self.numberLabel.frame limitedToNumberOfLines:2];
        drawingBounds = CGRectInset(drawingBounds, -4.0, -4.0);
        drawingBounds.origin.y = self.numberLabel.frame.origin.y;
        self.numberLabel.frame = drawingBounds;
        
        self.numberLabel.layer.borderColor = [UIColor colorWithRGBHex:0x3fa108].CGColor;
        self.numberLabel.layer.borderWidth = 1.0;
        self.numberLabel.layer.cornerRadius = 4.0;
*/
    }
    
    @IBAction func didTapButtonClose(sender: AnyObject) {
        
        if self.isExam && !self.solutionIsShown {
            println("\(__FUNCTION__)")
        }
        else if !self.isExam && !Settings.sharedSettings().solutionMode {
            
            var givenAnswersCount = 0
            for qm in self.questionModels {
                if qm.isAnAnswerGiven() {
                    givenAnswersCount++
                }
            }
            
            if givenAnswersCount > 0 {
                self.performSegueWithIdentifier("LearningResultViewController", sender: self)
            } else {
                self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
        
        
//        else if (!self.isExam && !self.userSettings.solutionMode) {
//            LearningResultViewController *lrvc = [[LearningResultViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.questionModels];
//            
//            if ([lrvc.questionModels count] > 0) {
//                [self.navigationController pushViewController:lrvc animated:YES];
//            }
//            else {
//                [self dismissViewControllerAnimated:YES completion:NULL];
//            }
//        }
        /**-
        if (self.isExam && !self.solutionIsShown) {
            if (self.iPad) {
                [((FahrschuleTabBarController *)self.tabBarController) setTabBarHidden:NO animated:YES];
            }
            
            if ([self.managedObjectContext hasChanges]) {
                NSError *error = nil;
                [self.managedObjectContext save:&error];
            }
            
            [self.examTimer invalidate];
            self.examTimer = nil;
            
            ExamStatistic *examStat = [ExamStatistic insertNewStatistics:self.managedObjectContext state:kCanceledExam];
            examStat.index = [NSNumber numberWithInt:self.currentQuestionIndex];
            examStat.timeLeft = [NSNumber numberWithInt:self.timeLeft];
            
            for (QuestionModel *qm in self.questionModels) {
                [examStat addStatisticsWithModel:qm inManagedObjectContext:self.managedObjectContext];
            }
            
            [self.managedObjectContext save:nil];
            
            if (self.iPad && (!self.userSettings.officialQuestionViewMode || !self.isExam)) {
                [self.fahrschuleNavigationController.popoverController dismissPopoverAnimated:YES];
                
                QuestionsTableViewController *qtvc = ((QuestionsTableViewController *)[[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] lastObject]);
                if (qtvc.view.window) {
                    [qtvc.navigationController popViewControllerAnimated:YES];
                }
                else {
                    [qtvc.navigationController popViewControllerAnimated:NO];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
            
            // Notify the tab bar controller that it should update the badge value for the exam icon. An exam has either been cancelled or handed in.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBadgeValue" object:nil];
        }
        else if (!self.isExam && !self.userSettings.solutionMode) {
            LearningResultViewController *lrvc = [[LearningResultViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.questionModels];
            
            if ([lrvc.questionModels count] > 0) {
                [self.navigationController pushViewController:lrvc animated:YES];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        }
        else {
            if ([self.managedObjectContext hasChanges]) {
                NSError *error = nil;
                [self.managedObjectContext save:&error];
            }
            
            [self.examTimer invalidate];
            self.examTimer = nil;
            
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
        
        */
    }
    
    

    // MARK:  - Collection View datasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.questionModels.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! InquirerCollectionCell
        
        let qModel = self.questionModels[indexPath.item]
        if self.solutionIsShown {
            qModel.hasSolutionBeenShown = true
        }
        
        cell.questionModel = qModel
        if self.isIPAD() {
            var tapRecoginezer = UITapGestureRecognizer(target: self, action: Selector("showFullscreenImage:"))
            cell.imageView.addGestureRecognizer(tapRecoginezer)
        }
        
        cell.favoriteButton.selected = qModel.question.isQuestionTagged()
        cell.favoriteButton.addTarget(self, action: Selector("didTapButtonFavorites:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }

    // MARK: - UICollectionView delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds) - collectionView.contentInset.top - collectionView.contentInset.bottom)
    }
    
    // MARK: - Scroll View delegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.configureView()
    }
    
    // MARK: - Private functions
    private func configureView() {
//        NavigationItem.Title
        self.currentIndex = Int(round(self.collectionView!.contentOffset.x / CGRectGetWidth(self.collectionView!.bounds)))
        let qModel: QuestionModel = self.questionModels[self.currentIndex]
        var title = "\(self.currentIndex + 1)/\(self.questionModels.count) |  \(qModel.question.points) Pkt."
        if qModel.question.number.hasSuffix("-M") {
            title += " | M"
        }
        self.navigationItem.title = title
        
//        Next & Prev buttons
        self.prevBarButton.enabled = !(self.currentIndex == 0)
        self.nextBarButton.enabled = (self.currentIndex + 1 < self.questionModels.count)
        
//        Solution button
        if let btn = self.solutionButton {
            btn.enabled = !qModel.hasSolutionBeenShown
        }

    }
    
    func showFullscreenImage(recognizer: UIGestureRecognizer) {
        println("\(NSStringFromClass(InquirerController.self)) \(__FUNCTION__)")
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
