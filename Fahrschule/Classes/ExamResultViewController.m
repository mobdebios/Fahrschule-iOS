//
//  ExamResultViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 21.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "ExamResultViewController.h"
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


@implementation ExamResultViewController

/*
- (Settings *)userSettings
{
    return [Settings sharedSettings];
}

- (UIColor *)correctColor
{
    return [UIColor colorWithRGBHex:0x006600];
}

- (UIColor *)incorrectColor
{
    return [UIColor colorWithRGBHex:0x9d0300];
}

- (UIColor *)titleBackgrondColor
{
    return [UIColor colorWithRGBHex:0x003f83];
}
 */

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withModels:(NSArray *)models
{
    NSString *nibName = self.userSettings.officialQuestionViewMode ? @"OfficialExamResultView" : @"ExamResultViewController";
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
        
        if (self.userSettings.officialQuestionViewMode) {
            if ([qm.question.containedIn.containedIn.baseMaterial boolValue]) {
                
                if (!qm.hasAnsweredCorrectly) {
                    mainGroupPoints += [qm.question.points intValue];
                }
                
                if ([mainGroupDict valueForKey:qm.question.containedIn.containedIn.name]) {
                    NSMutableArray *array = (NSMutableArray *)[mainGroupDict valueForKey:qm.question.containedIn.containedIn.name];
                    [array addObject:qm];
                }
                else {
                    [mainGroupDict setValue:[NSMutableArray arrayWithObject:qm] forKey:qm.question.containedIn.containedIn.name];
                    [sortedGroupArray addObject:qm.question.containedIn.containedIn.name];
                }
            }
            else {
                if ([additionalGroupDict valueForKey:qm.question.containedIn.containedIn.name]) {
                    NSMutableArray *array = (NSMutableArray *)[additionalGroupDict valueForKey:qm.question.containedIn.containedIn.name];
                    [array addObject:qm];
                }
                else {
                    [additionalGroupDict setValue:[NSMutableArray arrayWithObject:qm] forKey:qm.question.containedIn.containedIn.name];
                    [sortedGroupArray addObject:qm.question.containedIn.containedIn.name];
                }
            }
        }
    }
    
    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        [self.managedObjectContext save:&error];
    }
    
    if (self.userSettings.officialQuestionViewMode) { // Setup the official question layout.
        self.numberOfFaultsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Klasse %@ - %d Fehlerpunkte", @""), self.userSettings.licenseClassString, points];
        
        if (points > self.maxPoints || (numFivePointsQuestionFalse == 2 && points == 10 && self.maxPoints == 10)) {
            self.mascotFeedbackLabel.text = NSLocalizedString(@"nicht bestanden", @"");
            self.mascotFeedbackLabel.backgroundColor = self.incorrectColor;
        }
        else {
            self.mascotFeedbackLabel.text = NSLocalizedString(@"bestanden", @"");
            self.mascotFeedbackLabel.backgroundColor = self.correctColor;
        }
        
        NSInteger boxerPerRow = self.iPad ? 8 : 4;
        CGFloat boxStartX = self.iPad ? 647.0 : 270.0;
        CGFloat width = self.iPad ? 1016.0 : 472.0;
        if ([[UIScreen mainScreen] bounds].size.height == 568 ) {
            width = 560.0;
        }
        CGFloat currentYCoord = self.mascotFeedbackLabel.frame.origin.y + self.mascotFeedbackLabel.frame.size.height + 4.0;
        UILabel *mainGroupTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, currentYCoord, width, 29.0)];
        mainGroupTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Grundstoff - %d Fehlerpunkte", @""), mainGroupPoints];
        mainGroupTitleLabel.textAlignment = NSTextAlignmentCenter;
        mainGroupTitleLabel.textColor = [UIColor whiteColor];
        mainGroupTitleLabel.backgroundColor = self.titleBackgrondColor;
        [self.contentScrollView addSubview:mainGroupTitleLabel];
        currentYCoord += mainGroupTitleLabel.frame.size.height + 5.0;

        
        // Adding a section for every present subgroup in 'Grundstoff'
        for (int i = 0;i < [mainGroupDict count];i++) {
            NSString *key = [sortedGroupArray objectAtIndex:i];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4.0, currentYCoord, self.iPad ? 577.0 : 200.0, 40.0)];
            label.text = key;
            label.textColor = [UIColor blackColor];
            if ([key length] > 24 && !self.iPad) {
                label.font = [UIFont systemFontOfSize:14.0];
            }
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 2;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            [self.contentScrollView addSubview:label];

            
            // Add question squares for 'Grundstoff'
            NSMutableArray *array = (NSMutableArray *)[mainGroupDict valueForKey:key];
            NSInteger correct = 0;
            NSInteger index = 0;
            CGFloat loopYCoord = currentYCoord;
            for (QuestionModel *model in array) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(boxStartX + 47.0 * (index % boxerPerRow), loopYCoord, 43.0, 40.0);
                btn.tag = model.index;
                index++;
                if (index % boxerPerRow == 0 && index != [array count]) {
                    loopYCoord += btn.frame.size.height + 5.0;
                }
                
                if (model.hasAnsweredCorrectly) {
                    correct++;
                    btn.backgroundColor = self.correctColor;
                }
                else {
                    btn.backgroundColor = self.incorrectColor;
                }
                
                [btn addTarget:self action:@selector(questionSelected:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentScrollView addSubview:btn];
            }
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(self.iPad ? 597.0 : 220.0, currentYCoord, 50.0, 40.0)];
            label.text = [NSString stringWithFormat:@"%d/%d", correct, [array count]];
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            [self.contentScrollView addSubview:label];
            currentYCoord = loopYCoord + label.frame.size.height + (i + 1 == [mainGroupDict count] ? 5.0 : 13.0);

        }
        
        UILabel *subGroupTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, currentYCoord, width, 29.0)];
        subGroupTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Zusatzstoff Klasse %@ - %d Fehlerpunkte", @""),
                                   self.userSettings.licenseClassString, points - mainGroupPoints];
        subGroupTitleLabel.textAlignment = NSTextAlignmentCenter;
        subGroupTitleLabel.textColor = [UIColor whiteColor];
        subGroupTitleLabel.backgroundColor = self.titleBackgrondColor;
        [self.contentScrollView addSubview:subGroupTitleLabel];
        currentYCoord += subGroupTitleLabel.frame.size.height + 5.0;

        
        // Adding a section for every present subgroup in 'Zusatzstoff'
        for (int i = [mainGroupDict count];i < [sortedGroupArray count];i++) {
            NSString *key = [sortedGroupArray objectAtIndex:i];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4.0, currentYCoord, self.iPad ? 577.0 : 200.0, 40.0)];
            label.text = key;
            label.textColor = [UIColor blackColor];
            if ([key length] > 24 && !self.iPad) {
                label.font = [UIFont systemFontOfSize:14.0];
            }
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 2;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            [self.contentScrollView addSubview:label];

        
            // Add question squares for 'Zusatzstoff'
            NSMutableArray *array = (NSMutableArray *)[additionalGroupDict valueForKey:key];
            NSInteger correct = 0;
            NSInteger index = 0;
            CGFloat loopYCoord = currentYCoord;
            for (QuestionModel *model in array) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(boxStartX + 47.0 * (index % boxerPerRow), loopYCoord, 43.0, 40.0);
                btn.tag = model.index;
                index++;
                if (index % boxerPerRow == 0 && index != [array count]) {
                    loopYCoord += btn.frame.size.height + 5.0;
                }
                
                if (model.hasAnsweredCorrectly) {
                    correct++;
                    btn.backgroundColor = self.correctColor;
                }
                else {
                    btn.backgroundColor = self.incorrectColor;
                }
                
                [btn addTarget:self action:@selector(questionSelected:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentScrollView addSubview:btn];
            }
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(self.iPad ? 597.0 : 220.0, currentYCoord, 50.0, 40.0)];
            label.text = [NSString stringWithFormat:@"%d/%d", correct, [array count]];
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            [self.contentScrollView addSubview:label];
            currentYCoord = loopYCoord + label.frame.size.height + (i + 1 == [sortedGroupArray count] ? 5.0 : 13.0);

        }
        
        self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, currentYCoord);
    }
    else { // Setup the original question layout.
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
