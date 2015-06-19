//
//  ExamViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 16.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "ExamViewController.h"
#import "ExamStatistic.h"
#import "ExamQuestion.h"
//#import "UIColor+ColorWithHexString.h"
#import "Question.h"
#import "QuestionModel.h"
//#import "QuestionSheetViewController.h"
//#import "ProgressTableViewCell.h"
#import "GraphDiagramController.h"
//#import "FahrschuleTracking.h"
//#import "OfficialExamNavigationController.h"
//#import "FahrschuleTabBarController.h"


@implementation ExamViewController

@synthesize barChartView=_barChartView;
@synthesize viewSwitchSegmentedController=_viewSwitchSegmentedController;
@synthesize archiveViewController=_archiveViewController;
@synthesize showGraphButton=_showGraphButton;
@synthesize examDescriptionLabel=_examDescriptionLabel;


- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initInManagedObjectContext:context];
    if (self) {
        _viewSwitchSegmentedController = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Statistik", @""),
                                                                                    NSLocalizedString(@"Archiv", @""), nil]];
        animateViewFlip = YES;
        
        [self setTitle:NSLocalizedString(@"Prüfung", @"")];
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"pruefung.png"] tag:1]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:@"licenseClassChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:@"teachingTypeChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:@"updateBadgeValue" object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter"]]];
    
#ifdef FAHRSCHULE_LITE
    self.examDescriptionLabel.text = NSLocalizedString(@"Diese Version simuliert eine abgespeckte Prüfung mit 10 Fragen. Die Vollversion enthält die realen Prüfungsbedingungen.", @"");
#endif
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter"]]];
    
    if (!self.iPad) {
//        [self.viewSwitchSegmentedController setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.viewSwitchSegmentedController setSelectedSegmentIndex:0];
        [self.viewSwitchSegmentedController setTintColor:[UIColor colorWithRGBHex:0x727d94]];
        [self.viewSwitchSegmentedController addTarget:self action:@selector(showOldExamsTableView:) forControlEvents:UIControlEventValueChanged];
        [self.navigationItem setTitleView:self.viewSwitchSegmentedController];
        
        _archiveViewController = [[ExamArchiveViewController alloc] initInManagedObjectContext:self.managedObjectContext];
        self.archiveViewController.examViewController = self;
        [self.view addSubview:self.archiveViewController.view];
        self.archiveViewController.view.hidden = YES;
    }
    else {
        self.view.autoresizingMask |= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


        
        // Add start exam and graph buttons
        UIBarButtonItem *startExamButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start", @"")
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(startExam:)];
        
        self.showGraphButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Statistik", @"")
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(showGraph:)];
        
        CustomToolbar *buttonHolder = [[CustomToolbar alloc] initWithFrame:CGRectZero];
        buttonHolder.barStyle = UIBarStyleBlackOpaque;
        buttonHolder.items = [NSArray arrayWithObjects:startExamButton, self.showGraphButton, nil];
        buttonHolder.frame = CGRectZero;
        
        UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonHolder];
        self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
        
        buttonHolder.frame = CGRectMake(0.0, 0.0, 132.0, self.navigationController.navigationBar.frame.size.height);
        
        self.archiveViewController = [[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
        
        self.showGraphButton.enabled = [self.archiveViewController.dataSource count] > 0;
    }
    
    [self.barChartView setPlaceholder:[UIImage imageNamed:@"image_pruefung.png"]];
    
    [self settingsChanged];
    */
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Archiv", @"");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return self.iPad || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return self.iPad;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.iPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait && !self.iPad &&
        (UIInterfaceOrientationIsLandscape(currentOrientation) || currentOrientation == 0 || currentOrientation == 5)) {
        [[FahrschuleTracking sharedInstance] sendPixelWithID:@"C7"];
        GraphDiagramController *gdc = [[GraphDiagramController alloc] initInManagedObjectContext:self.managedObjectContext];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.navigationController pushViewController:gdc animated:NO];
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ExamStatistic *examStat = [[ExamStatistic statisticsInManagedObjectContext:self.managedObjectContext fetchLimit:-1 state:kCanceledExam] lastObject];
    if (buttonIndex == 2) {
        [examStat deleteExamInManagedObjectContext:self.managedObjectContext];
        [self startExamWithModels:[QuestionModel modelsForQuestions:[Question examQuestionsInManagedObjectContext:self.managedObjectContext]] examStatistics:nil];
    }
    else if (buttonIndex == 1) {
        [self startExamWithModels:[examStat questionModelsForExam] examStatistics:examStat];
    }
}

#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self alertView:nil clickedButtonAtIndex:buttonIndex + 1];
}

#pragma mark - Actions

- (void)showOldExamsTableView:(id)sender
{
    if (!animateViewFlip) {
        [self.archiveViewController.view setHidden:YES];
        animateViewFlip = YES;
        return;
    }
    
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:NO];
    switch (segControl.selectedSegmentIndex) {
        case 0:
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
            [self.archiveViewController.view setHidden:YES];
            break;
        case 1:
            [[FahrschuleTracking sharedInstance] sendPixelWithID:@"C6"];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
            self.archiveViewController.dataSource = [ExamStatistic statisticsInManagedObjectContext:self.managedObjectContext fetchLimit:0];
            [self.archiveViewController.tableView reloadData];
            [self.archiveViewController.view setHidden:NO];
            break;
        default:
            break;
    }
    
    [UIView commitAnimations];
}

- (IBAction)startExam:(id)sender {
    [[FahrschuleTracking sharedInstance] sendPixelWithID:@"C2"];
    
    ExamStatistic *examStat = [[ExamStatistic statisticsInManagedObjectContext:self.managedObjectContext fetchLimit:-1 state:kCanceledExam] lastObject];
    
    if (examStat) {
        if (self.iPad) {
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Möchtest du die letzte Prüfung fortsetzen?", @"")
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Prüfung fortsetzen", @""),
                                                                        NSLocalizedString(@"Neue Prüfung starten", @""), nil];
            action.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [action showInView:self.view];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:NSLocalizedString(@"Möchtest du die letzte Prüfung fortsetzen?", @"")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"")
                                                   otherButtonTitles:NSLocalizedString(@"Prüfung fortsetzen", @""),
                                                                     NSLocalizedString(@"Neue Prüfung starten", @""), nil];
            [alert show];
        }
        
    }
    else {
        [self startExamWithModels:[QuestionModel modelsForQuestions:[Question examQuestionsInManagedObjectContext:self.managedObjectContext]] examStatistics:nil];
    }
}

- (void)settingsChanged
{
    if (self.iPad) {
        self.archiveViewController.dataSource = [ExamStatistic statisticsInManagedObjectContext:self.managedObjectContext fetchLimit:0];
        [self.archiveViewController.tableView reloadData];
        
        self.showGraphButton.enabled = [self.archiveViewController.dataSource count] > 0;
    }
    else if (self.viewSwitchSegmentedController.selectedSegmentIndex == 1) {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        animateViewFlip = version >= 5.0;
        
        [self.viewSwitchSegmentedController setSelectedSegmentIndex:0];
        
        [self.archiveViewController.view setHidden:YES];
    }
	
    NSInteger limit = self.iPad ? 10 : 6;
	NSArray *exams = [ExamStatistic statisticsInManagedObjectContext:self.managedObjectContext fetchLimit:limit];
	
    if ([exams count] > 0) {
        [self.viewSwitchSegmentedController setEnabled:YES forSegmentAtIndex:1];
    }
    else {
        [self.viewSwitchSegmentedController setEnabled:NO forSegmentAtIndex:1];
    }
    
    NSDictionary *examSheetDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ExamSheet" ofType:@"plist"]];
    self.barChartView.maxPoints = [[[[examSheetDictionary objectForKey:[NSString stringWithFormat:@"%d", self.userSettings.licenseClass]]
                                     objectForKey:[NSString stringWithFormat:@"%d", self.userSettings.teachingType]] objectForKey:@"MaxPoints"] intValue];
    
    [self.barChartView clearItems];
    
    for (ExamStatistic *exam in exams) {
        [self.barChartView addItemValue:[exam.faultyPoints intValue] passed:[exam hasPassed] date:exam.date];
    }
    
	self.barChartView.alpha = 0.0;
	[self.barChartView setHidden:NO];
	[self.barChartView setNeedsDisplay];
    
	// Animate the fade-in
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	self.barChartView.alpha = 1.0;
	[UIView commitAnimations];

}

- (void)showGraph:(id)sender
{
    [[FahrschuleTracking sharedInstance] sendPixelWithID:@"C7"];
    
    GraphDiagramController *gdc = [[GraphDiagramController alloc] initInManagedObjectContext:self.managedObjectContext];
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:gdc];
    navCon.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self.splitViewController presentViewController:navCon animated:YES completion:nil];
}

#pragma mark - Helper functions

- (void)startExamWithModels:(NSArray *)models examStatistics:(ExamStatistic *)examStat
{
    // If in some rare cases the number of models is zero, rather then let the application crash, return and do nothing
    if ([models count] == 0) return;
    
    QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:models];
    qsvc.isExam = YES;
    qsvc.isOfficialLayout = self.userSettings.officialQuestionViewMode;
    
    // Lock orientation to portrait to prevent tab view controller to change it's orientation while doing the exam.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lockPortraitOrientation" object:nil];
    
    if (examStat) {
        qsvc.timeLeft = [examStat.timeLeft intValue];
        qsvc.currentQuestionIndex = [examStat.index intValue];
    }
    
    if (self.iPad && !self.userSettings.officialQuestionViewMode) {
        
        // Hide tab bar. In exam mode the user should focus on the exam and not be able to switch between tabs.
        [((FahrschuleTabBarController *)self.tabBarController) setTabBarHidden:YES animated:YES];
        
        qsvc.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
        [self.navigationController pushViewController:qsvc animated:YES];
        
        QuestionsTableViewController *qtvc = [[QuestionsTableViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:models];
        qtvc.navigationItem.hidesBackButton = YES;
        qtvc.isExam = YES;
        qtvc.title = NSLocalizedString(@"Prüfungsfragen", @"");
        qtvc.currentIndexPath = [NSIndexPath indexPathForRow:qsvc.currentQuestionIndex inSection:0];
        [[self.splitViewController.viewControllers objectAtIndex:0] pushViewController:qtvc animated:YES];
        qtvc.navigationItem.rightBarButtonItem = nil;
    }
    else {
        UINavigationController *navcon = self.userSettings.officialQuestionViewMode ? [[OfficialExamNavigationController alloc] init] : [[UINavigationController alloc] init];
        navcon.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter.png"]];
        [navcon.navigationBar setBarStyle:UIBarStyleBlackOpaque];
        [navcon pushViewController:qsvc animated:NO];
        [self presentViewController:navcon animated:YES completion:nil];
    }
}

*/

@end
