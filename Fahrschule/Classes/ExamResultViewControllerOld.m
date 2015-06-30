//
//  ExamResultViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 21.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "ExamResultViewControllerOld.h"
#import "ExamStatistic.h"
#import "Question.h"
#import "QuestionModel.h"
//#import "QuestionSheetViewController.h"

//#import "FahrschuleTabBarController.h"
//#import "UIColor+ColorWithHexString.h"
#import "MainGroup.h"
#import "SubGroup.h"
//#import "OfficialExamNavigationController.h"

#ifdef FAHRSCHULE_LITE
#import "BuyFullVersionViewController.h"
#endif


@implementation ExamResultViewControllerOld



- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withModels:(NSArray *)models
{
    NSString *nibName = self.userSettings.officialQuestionViewMode ? @"OfficialExamResultView" : @"ExamResultViewControllerOld";
    self = [super initWithNibName:nibName inManagedObjectContext:context];
    if (self) {
        self.questionModels = models;
        self.timeLeft = 0;
        
        NSDictionary *examSheetDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ExamSheet" ofType:@"plist"]];
        self.maxPoints = [[[[examSheetDictionary objectForKey:[NSString stringWithFormat:@"%d", self.userSettings.licenseClass]]
                                         objectForKey:[NSString stringWithFormat:@"%d", self.userSettings.teachingType]] objectForKey:@"MaxPoints"] intValue];
        
        [self setTitle:NSLocalizedString(@"Ergebnis", @"")];
        
        self.navigationItem.hidesBackButton = YES;
    }
    
    return self;
}

#pragma mark - View lifecycle
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.autoresizingMask |= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    ExamStatistic *examStat = [ExamStatistic insertNewStatistics:self.managedObjectContext state:kFinishedExam];
    examStat.index = [NSNumber numberWithInt:0];
    examStat.timeLeft = [NSNumber numberWithInt:self.timeLeft];
    
    NSInteger points = 0;
    NSInteger mainGroupPoints = 0;
    NSInteger numFivePointsQuestionFalse = 0;
    NSMutableDictionary *mainGroupDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *additionalGroupDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *sortedGroupArray = [[NSMutableArray alloc] init];
    for (QuestionModel *qm in self.questionModels) {
        [examStat addStatisticsWithModel:qm inManagedObjectContext:self.managedObjectContext];
        
        if (![qm hasAnsweredCorrectly]) {
            points += [qm.question.points intValue];
            if ([qm.question.points intValue] == 5) {
                numFivePointsQuestionFalse++;
            }
        }
 
    }
    
    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        [self.managedObjectContext save:&error];
    }
    
    { // Setup the original question layout.
        if (points > self.maxPoints || (numFivePointsQuestionFalse == 2 && points == 10 && self.maxPoints == 10)) {
            self.mascotImageView.image = [UIImage imageNamed:@"image_endpruefung_nichtBestanden.png"];
        }
        else if (points == 0) {
            self.showFaultsButton.enabled = NO;
        }
        
        self.numberOfFaultsLabel.text = [NSString stringWithFormat:@"%d Punkte", points];
        self.handinTimeLabel.text = [self handinTimeString];
        
        if (points == 0) {
            self.mascotFeedbackLabel.text = NSLocalizedString(@"Fehlerlos! Hervorragend!", @"");
        }
        else if (points <= self.maxPoints || (numFivePointsQuestionFalse != 2 && points == 10 && self.maxPoints == 10)) {
            self.mascotFeedbackLabel.text = NSLocalizedString(@"Gratulation, bestanden!", @"");
        }
        else if ((points > self.maxPoints && points <= 20) || (numFivePointsQuestionFalse == 2 && points == 10 && self.maxPoints == 10)) {
            self.mascotFeedbackLabel.text = NSLocalizedString(@"Nicht schlecht, dranbleiben!", @"");
        }
        else if (points > 20 && points <= 60) {
            self.mascotFeedbackLabel.text = NSLocalizedString(@"Naja - üben, üben, üben!", @"");
        }
        else {
            self.mascotFeedbackLabel.text = NSLocalizedString(@"Ohje! Es gibt noch viel zu lernen.", @"");
        }
        
        if (self.iPad) {
            UIBarButtonItem *retryPreviousExamButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Prüfung wiederholen", @"")
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(retryPreviousExam:)];
            self.navigationItem.rightBarButtonItem = retryPreviousExamButton;

        }
    }
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Schließen", @"")
                                                                     style:UIBarButtonItemStylePlain target:self action:@selector(closeModalView:)];
    if (!self.iPad || self.userSettings.officialQuestionViewMode) {
        [self.navigationItem setLeftBarButtonItem:closeButton animated:NO];
    }
    else {
        [[[[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] lastObject] navigationItem] setHidesBackButton:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.iPad) {
        if (self.userSettings.officialQuestionViewMode) {
            return UIInterfaceOrientationIsLandscape(interfaceOrientation);
        }
        
        return YES;
    }
    
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait && !self.userSettings.officialQuestionViewMode) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight && self.userSettings.officialQuestionViewMode));
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.iPad) {
        if (self.userSettings.officialQuestionViewMode) {
            return UIInterfaceOrientationMaskLandscape;
        }
        
        return UIInterfaceOrientationMaskAll;
    }
    
    return self.userSettings.officialQuestionViewMode ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationPortrait;
}

#pragma mark - Actions

- (IBAction)closeModalView:(id)sender
{
    if (self.iPad && !self.userSettings.officialQuestionViewMode) {
        [[self.splitViewController.viewControllers objectAtIndex:0] popToRootViewControllerAnimated:YES];
        [[self.splitViewController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:YES];
    }
    else {
#ifdef FAHRSCHULE_LITE
        BuyFullVersionViewController *bfvvc = [[BuyFullVersionViewController alloc] initWithOfficialView:self.userSettings.officialQuestionViewMode];
        [self.navigationController pushViewController:bfvvc animated:YES];
        [bfvvc release];
#else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
#endif
    }
}

- (IBAction)retryPreviousExam:(id)sender
{
    if (self.iPad) {
        
        QuestionsTableViewController *qtvc = [[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] lastObject];
        NSArray *models = qtvc.dataSource;
        for (QuestionModel *model in models) {
            model.givenAnswers = nil;
            [model setHasSolutionBeenShown:NO];
        }
        
        // If the user switches to official exam layout on the exam result screen and then chooses to retry the exam.
        if (self.userSettings.officialQuestionViewMode) {
            QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:models];
            qsvc.isExam = YES;
            qsvc.isOfficialLayout = YES;
            
            OfficialExamNavigationController *navcon = [[OfficialExamNavigationController alloc] init];
            navcon.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter.png"]];
            [navcon.navigationBar setBarStyle:UIBarStyleBlackOpaque];
            [navcon pushViewController:qsvc animated:NO];
            [self presentViewController:navcon animated:YES completion:nil];

            
            [[self.splitViewController.viewControllers objectAtIndex:0] popToRootViewControllerAnimated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            QuestionSheetViewController *qsvc = nil;
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[QuestionSheetViewController class]]) {
                    qsvc = (QuestionSheetViewController *) viewController;
                }
            }
            
            if (qsvc && qtvc) {
                qsvc.retryExam = YES;
                qtvc.isExamHistory = NO;
                qtvc.isExam = YES;
                qtvc.navigationItem.hidesBackButton = YES;
                [qtvc.tableView reloadData];
                qtvc.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [qtvc.tableView selectRowAtIndexPath:qtvc.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                
                [((FahrschuleTabBarController *)self.tabBarController) setTabBarHidden:YES animated:YES];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
    }
    else {
        UIViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
        if ([viewController isKindOfClass:[QuestionSheetViewController class]]) {
            ((QuestionSheetViewController *)viewController).retryExam = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)examineExam:(id)sender
{
    QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.questionModels];
    qsvc.solutionIsShown = YES;
    qsvc.isExam = YES;
    qsvc.showCloseButton = NO;
    
    [self.navigationController pushViewController:qsvc animated:YES];
}

- (IBAction)examinefaultyQuestions:(id)sender
{
    if (!_faultyQuestionModels) {
        NSMutableArray *models = [[NSMutableArray alloc] init];
        NSInteger index = 0;
        for (QuestionModel *model in self.questionModels) {
            if (![model hasAnsweredCorrectly]) {
                QuestionModel *newModel = [[QuestionModel alloc] initWithQuestion:model.question atIndex:index++];
                newModel.givenAnswers = [NSMutableArray arrayWithArray:model.givenAnswers];
                [models addObject:newModel];
            }
        }
        self.faultyQuestionModels = [NSArray arrayWithArray:models];
    }
    
    QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.faultyQuestionModels];
    qsvc.solutionIsShown = YES;
    qsvc.isExam = YES;
    qsvc.showCloseButton = NO;
    
    [self.navigationController pushViewController:qsvc animated:YES];
}

- (IBAction)questionSelected:(id)sender
{
    QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.questionModels];
    qsvc.solutionIsShown = YES;
    qsvc.isExam = YES;
    qsvc.isOfficialLayout = self.userSettings.officialQuestionViewMode;
    qsvc.showCloseButton = NO;
    qsvc.currentQuestionIndex = [sender tag];
    
    [self.navigationController pushViewController:qsvc animated:YES];
}

#pragma mark - Helper functions

- (NSString *)handinTimeString
{
    NSInteger time = 60 * 60 - self.timeLeft;
    if (time < 60) {
        return [NSString stringWithFormat:@"%d sek.", time];
    }
    time = (NSInteger)floorf(time / 60.0);
    return [NSString stringWithFormat:@"%d min.", time];
}
*/
 
@end
