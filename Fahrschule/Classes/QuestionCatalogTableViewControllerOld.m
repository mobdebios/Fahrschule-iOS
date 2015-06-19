//
//  QuestionCatalogTableViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 17.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "QuestionCatalogTableViewControllerOld.h"
#import "MainGroup.h"
#import "Question.h"
#import "QuestionModel.h"
#import "SubGroup.h"

//#import "QuestionViewController.h"
//#import "QuestionSheetViewController.h"
//#import "ProgressTableViewCell.h"
#import "LearningStatistic.h"

//#import "QuestionTableViewCell.h"
//#import "FahrschuleTracking.h"
#import "Checksum.h"


#import "Fahrschule-Swift.h"

#define NUM_OF_SECTIONS 2

#define PROGRESS_CELL @"PROGRESS_CELL"

@interface QuestionCatalogTableViewControllerOld () <UITableViewDataSource, UITableViewDelegate> {
    NSInteger numberOfThemes[2];
}

@property (nonatomic, retain) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property BOOL isSearching;

@end

@implementation QuestionCatalogTableViewControllerOld

//@synthesize searchDisplayController=__searchDisplayController;



//- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
//{
//    self = [super initInManagedObjectContext:context];
//    if (self) {
//        self.lastUpdate = [NSDate distantPast];
//        
////        self.searchBar.placeholder = NSLocalizedString(@"Frage suchen", @"");
//        
////        __searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
////        self.searchDisplayController.delegate = self; 
////        self.searchDisplayController.searchResultsDataSource = self;
////        self.searchDisplayController.searchResultsDelegate = self;
//        
//        
////        _progressDict = [[NSMutableDictionary alloc] init];
//        
////        [self setTitle:NSLocalizedString(@"Katalog", @"")];
//        
//#ifndef FAHRSCHULE_LITE
//        // Integrity Check
//        NSString *sha1 = [Checksum plistSHA1];
//#if defined (DEBUG)
//        NSLog(@"Info.plist SHA1: %@", sha1);
//#endif
//        if (![sha1 isEqualToString:INFO_PLIST_SHA1]) {
//            
////            int rnd = arc4random() % ((unsigned)25) + 5;
//#if defined (DEBUG)
////            NSLog(@"App is compromized! Shutdown in %d seconds.", rnd);
//#endif
//            // Info.plist has another SHA1 checksum as the shipped version. This app har been compromized. Shutdown after 5 - 30 seconds.
////            [self performSelector:@selector(fetchQuestions:) withObject:nil afterDelay:rnd];
//        }
//
//#endif
//        
//        // Add observers for receiving information from other view controllers about license class change.
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTagQuestion) name:@"tagQuestion" object:nil];
//
//        if (self.iPad) {
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(licenseClassChanged) name:@"licenseClassChanged" object:nil];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAnswersGiven:) name:@"didChangeAnswersGiven" object:nil];
//        }
//    }
//    return self;
//}

#pragma mark - Initialization
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTagQuestion) name:@"tagQuestion" object:nil];
        if (DEIVECE_IS_IPAD) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(licenseClassChanged) name:@"licenseClassChanged" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAnswersGiven:) name:@"didChangeAnswersGiven" object:nil];
        }
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
    
//    Segmented control
    [self.segmentedControl setEnabled:NO forSegmentAtIndex:1];
    
//    Table View
    [self.tableView registerNib:[UINib nibWithNibName:@"ProgressCell" bundle:nil] forCellReuseIdentifier:PROGRESS_CELL];
    self.tableView.estimatedRowHeight = 44.f;
    
//    self.tableView.tableHeaderView = self.searchBar;
//    
//	[self.navigationItem setTitleView:self.viewSwitchSegmentedController];
//    
//    UIBarButtonItem *startLearningButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abfragen", @"")
//                                style:UIBarButtonItemStylePlain target:self action:@selector(showActionSheet:)];
//    [self.navigationItem setRightBarButtonItem:startLearningButton];
//    
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    numberOfThemes[0] = 0;
    numberOfThemes[1] = 0;
    NSArray *mainGroups = [MainGroup mainGroupsInManagedObjectContext:self.managedObjectContext];
    NSMutableArray *mainGroupsArray = [[NSMutableArray alloc] init];
    for (MainGroup *mainGroup in mainGroups) {

#ifndef FAHRSCHULE_LITE
        NSUInteger numOfQuestions = [Question countQuestionsInRelationsTo:mainGroup inManagedObjectContext:self.managedObjectContext];
        if (numOfQuestions == 0) continue;
#endif
        [mainGroupsArray addObject:mainGroup];
        if ([mainGroup.baseMaterial boolValue]) {
            numberOfThemes[0]++;
        }
        else {
            numberOfThemes[1]++;
        }   
    }
    
    self.dataSource = [NSArray arrayWithArray:mainGroupsArray];
    self.mainGroupArray = self.dataSource;

    
//    [self didTagQuestion];
    
#ifdef FAHRSCHULE_LITE
    [self showbannerFullversionAnimated];
#endif
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    
    /**
    LearningStatistic *stat = [LearningStatistic latestStatistic:self.managedObjectContext];
	
	NSDate *statisticsLastUpdated = [NSDate distantPast];
	if (stat) {
		statisticsLastUpdated = stat.date;
	}
    
    if (!self.isLearningMode) {
        if ([self isCatalogSelected]) {
            self.tableView.contentOffset = CGPointMake(0.0, 44.0);
        }
        else {
            NSArray *taggedQuestions = [Question taggedQuestionsInManagedObjectContext:self.managedObjectContext];
            if ([taggedQuestions count] == 0) {
                self.tableView.tableHeaderView = self.searchBar;
                self.dataSource = self.mainGroupArray;
                [self.viewSwitchSegmentedController setSelectedSegmentIndex:0];
                [self.viewSwitchSegmentedController setEnabled:NO forSegmentAtIndex:1];
            }
            else {
                self.dataSource = [QuestionModel modelsForQuestions:taggedQuestions];
            }
            
            [self.tableView reloadData];
        }
    }
    
    if ([[statisticsLastUpdated earlierDate:self.lastUpdate] isEqualToDate:self.lastUpdate] || !stat) {
        [self.progressDict removeAllObjects];
        self.lastUpdate = [NSDate date];
        [self.tableView reloadData];
        
        if ([self isCatalogSelected] && self.isSearching) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }
     */
}

/**
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.mainGroupArray count] != [self.progressDict count]) {
        for (int i = 0; i < [self.mainGroupArray count]; i++) {
            if (![self.progressDict objectForKey:[NSNumber numberWithInt:i]]) {
                [self progressItemForMainGroupAtIndex:i];
            }
        }
    }
}
 
*/

#pragma mark - Private Methods
- (BOOL)isCatalogSelected {
    return self.segmentedControl.selectedSegmentIndex == 0;
}


#pragma mark - Property Accessors
- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[SNAppDelegate sharedDelegate] managedObjectContext];
    }
    return _managedObjectContext;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
}

#pragma mark - Outlet Methods
- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
//    if (![self isCatalogSelected] || self.isSearching) return 1;
    
    return NUM_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
//    if (![self isCatalogSelected] || self.isSearching) return [self.dataSource count];
    
    return numberOfThemes[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

//    if (![self isCatalogSelected] || self.isSearching) return @"";
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"Grundstoff", @"");
        case 1:
            return NSLocalizedString(@"Zusatzstoff", @"");
        default:
            break;
    }
    
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:PROGRESS_CELL forIndexPath:indexPath];
    
    MainGroup *mainGroup = (MainGroup *)[self.dataSource objectAtIndex:indexPath.section * numberOfThemes[0] + indexPath.row];
    cell.titleLabel.text = mainGroup.name;
    cell.iconImageView.image = [mainGroup mainGroupImage];
    
    if (!cell.iconImageView.image) {
        NSLog(@"%s %@", __FUNCTION__, mainGroup.image);
    }
    
    return cell;
}



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *SearchCellIdentifier = @"SearchCell";
    
    if ([self isCatalogSelected] && !self.isSearching) {
        
        ProgressTableViewCell *cell = (ProgressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ProgressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        MainGroup *mainGroup = (MainGroup *)[self.dataSource objectAtIndex:indexPath.section * numberOfThemes[0] + indexPath.row];
        cell.primaryLabel.text = mainGroup.name;
        cell.primaryLabel.frame = CGRectMake(44.0, 0.0, 176.0, 44.0);
        cell.imageView.image = [mainGroup mainGroupImage];
        cell.progressView.hidden = NO;
        
        ProgressItem *item = [self.progressDict objectForKey:[NSNumber numberWithInt:(indexPath.section * numberOfThemes[0] + indexPath.row)]];
        if (!item) {
            item = [self progressItemForMainGroupAtIndex:(indexPath.section * numberOfThemes[0] + indexPath.row)];
        }
        cell.progressView.progressValue = item;
        
        if (!self.iPad) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
#ifdef FAHRSCHULE_LITE
        if (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 5)) {
            cell.primaryLabel.textColor = self.iPad ? [UIColor whiteColor] : [UIColor blackColor];
            cell.imageView.alpha = 1.0;
            cell.userInteractionEnabled = YES;
            cell.progressView.hidden = NO;
        }
        else {
            cell.primaryLabel.textColor = [UIColor lightGrayColor];
            cell.imageView.alpha = 0.6;
            cell.userInteractionEnabled = NO;
            cell.progressView.hidden = YES;
        }
#endif
        
        return cell;
    }
    else {
        
        QuestionTableViewCell *cell = (QuestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
        if (cell == nil) {
            cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
        }
        
        QuestionModel *model = (QuestionModel *)[self.dataSource objectAtIndex:indexPath.row];
        cell.numberLabel.text = model.question.number;
        cell.textLabel.text = model.question.text;
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (self.iPad) {
            [cell setDisplayState:[model isAnAnswerGiven]];
        }
        
        if (model.question.learnStats && [model.question.learnStats count] > 0) {
            for (LearningStatistic *learnStat in model.question.learnStats) {
                if([learnStat.licenseClass intValue] == self.userSettings.licenseClass) {
                    switch ([learnStat.state intValue]) {
                        case kCorrectAnswered:
                            cell.statisticIndicatorImageView.image = [UIImage imageNamed:@"icon_richtig.png"];
                            break;
                        case kFaultyAnswered:
                            cell.statisticIndicatorImageView.image = [UIImage imageNamed:@"icon_falsch.png"];
                            break;
                    }
                }
            }
        }
        else {
            cell.statisticIndicatorImageView.image = nil;
        }
        
        return cell;
    }
}

*/


/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (![self isCatalogSelected] || self.isSearching) return 0.0;
    
    return tableView.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil || [sectionTitle isEqualToString:@""]) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, tableView.sectionHeaderHeight)];
    [label setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_section_header.png"]]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont boldSystemFontOfSize:15.0]];
    [label setText:sectionTitle];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *SearchCellIdentifier = @"SearchCell";
    
    if ([self isCatalogSelected] && !self.isSearching) {
    
        ProgressTableViewCell *cell = (ProgressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ProgressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        MainGroup *mainGroup = (MainGroup *)[self.dataSource objectAtIndex:indexPath.section * numberOfThemes[0] + indexPath.row];
        cell.primaryLabel.text = mainGroup.name;
        cell.primaryLabel.frame = CGRectMake(44.0, 0.0, 176.0, 44.0);
        cell.imageView.image = [mainGroup mainGroupImage];
        cell.progressView.hidden = NO;
        
        ProgressItem *item = [self.progressDict objectForKey:[NSNumber numberWithInt:(indexPath.section * numberOfThemes[0] + indexPath.row)]];
        if (!item) {
            item = [self progressItemForMainGroupAtIndex:(indexPath.section * numberOfThemes[0] + indexPath.row)];
        }
        cell.progressView.progressValue = item;
        
        if (!self.iPad) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
#ifdef FAHRSCHULE_LITE
        if (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 5)) {
            cell.primaryLabel.textColor = self.iPad ? [UIColor whiteColor] : [UIColor blackColor];
            cell.imageView.alpha = 1.0;
            cell.userInteractionEnabled = YES;
            cell.progressView.hidden = NO;
        }
        else {
            cell.primaryLabel.textColor = [UIColor lightGrayColor];
            cell.imageView.alpha = 0.6;
            cell.userInteractionEnabled = NO;
            cell.progressView.hidden = YES;
        }
#endif
        
        return cell;
    }
    else {

        QuestionTableViewCell *cell = (QuestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
        if (cell == nil) {
            cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
        }
        
        QuestionModel *model = (QuestionModel *)[self.dataSource objectAtIndex:indexPath.row];
        cell.numberLabel.text = model.question.number;
        cell.textLabel.text = model.question.text;
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (self.iPad) {
            [cell setDisplayState:[model isAnAnswerGiven]];
        }
        
        if (model.question.learnStats && [model.question.learnStats count] > 0) {
            for (LearningStatistic *learnStat in model.question.learnStats) {
                if([learnStat.licenseClass intValue] == self.userSettings.licenseClass) {
                    switch ([learnStat.state intValue]) {
                        case kCorrectAnswered:
                            cell.statisticIndicatorImageView.image = [UIImage imageNamed:@"icon_richtig.png"];
                            break;
                        case kFaultyAnswered:
                            cell.statisticIndicatorImageView.image = [UIImage imageNamed:@"icon_falsch.png"];
                            break;
                    }
                }
            }
        }
        else {
            cell.statisticIndicatorImageView.image = nil;
        }
        
        return cell;
    }
}

*/
 
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCatalogSelected] && !self.isSearching) {
        
        [self performSegueWithIdentifier:@"SubGroupTableViewController" sender:self];
        
//        int offset = indexPath.section == 1 ? numberOfThemes[0] : 0;
//        MainGroup *mainGroup = (MainGroup *)[self.dataSource objectAtIndex:offset + indexPath.row];
//        
//        SubGroupTableViewController *sgtvc = [[SubGroupTableViewController alloc] initInManagedObjectContext:self.managedObjectContext withMainGroup:mainGroup];
//        [sgtvc setTitle:mainGroup.name];
//        [self.navigationController pushViewController:sgtvc animated:YES];
//
//        
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        /**
        UIViewController *controller = [[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] lastObject];
        if ([controller isKindOfClass:[QuestionSheetViewController class]]) {
            [((QuestionSheetViewController *)controller) switchToQuestionWithIndex:indexPath.row];
        }
        else {
            QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext
                                                                                                     withModels:self.dataSource];
            qsvc.currentQuestionIndex = indexPath.row;
            qsvc.navigationItem.leftBarButtonItem = [[[self.fahrschuleNavigationController.viewControllers lastObject] navigationItem] leftBarButtonItem];
            
            if (self.iPad) {
                UIViewController *controller = [[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] lastObject];
                if ([controller isKindOfClass:[QuestionSheetViewController class]]) {
                    [((QuestionSheetViewController *)controller) switchToQuestionWithIndex:indexPath.row];
                }
                else {
                    
                    if (self.isLearningMode) {
                        qsvc.solutionIsShown = YES;
                        qsvc.isExam = NO;
                        qsvc.showCloseButton = NO;
                    }
                    else {
                        if (![self isCatalogSelected]) {
                            UIBarButtonItem *finishLearningModeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Beenden", @"")
                                                                                                         style:UIBarButtonItemStylePlain
                                                                                                        target:self
                                                                                                        action:@selector(finishLearning:)];
                            
                            // Setup new navigation elements during learning.
                            [self.navigationItem setLeftBarButtonItem:finishLearningModeButton animated:YES];
                            [self setRightBarButtonHidden:YES];
                            self.navigationItem.titleView.hidden = YES;
                        }
                        
                        [[self.splitViewController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:NO];
                    }
                    
                    // We are now in learning mode. Exchange the back button with the "Beenden" button.
                    self.isLearningMode = YES;
                    
                    qsvc.navigationItem.rightBarButtonItem = [[[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] lastObject] navigationItem] rightBarButtonItem];
                    [[self.splitViewController.viewControllers objectAtIndex:1] pushViewController:qsvc animated:YES];
                }
                
                [self.fahrschuleNavigationController.popoverController dismissPopoverAnimated:YES];
            }
            else {
                UINavigationController *navcon = [[UINavigationController alloc] init];
                navcon.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter.png"]];
                navcon.navigationBar.barStyle = UIBarStyleBlack;
                [navcon pushViewController:qsvc animated:NO];
                [self presentViewController:navcon animated:YES completion:nil];

                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
         }*/

        
//        self.currentIndexPath = indexPath;
    }
}


/*
#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 4) return;
    
    if (self.iPad) {
        [self.fahrschuleNavigationController.popoverController dismissPopoverAnimated:YES];
    }
    NSArray *questions = nil;
    switch (buttonIndex) {
        case 0:
            questions = [self isCatalogSelected] ? [Question questionsInRelationsTo:nil inManagedObjectContext:self.managedObjectContext] :
                [Question taggedQuestionsInManagedObjectContext:self.managedObjectContext];
            break;
        case 1:
            questions = [self isCatalogSelected] ? [Question questionsInRelationsTo:nil state:kFaultyAnswered inManagedObjectContext:self.managedObjectContext] :
                [Question taggedQuestionsInManagedObjectContext:self.managedObjectContext state:kFaultyAnswered];
            break;
        case 2:
            questions = [self isCatalogSelected] ? [Question questionsInRelationsTo:nil state:kStateLess inManagedObjectContext:self.managedObjectContext] :
                [Question taggedQuestionsInManagedObjectContext:self.managedObjectContext state:kStateLess];
            break;
        case 3:
            if ([self isCatalogSelected]) {
                questions = [Question questionsInRelationsTo:nil state:kFaultyAnswered inManagedObjectContext:self.managedObjectContext];
                questions = [questions arrayByAddingObjectsFromArray:[Question questionsInRelationsTo:nil state:kStateLess inManagedObjectContext:self.managedObjectContext]];
            }
            else {
                questions = [Question taggedQuestionsInManagedObjectContext:self.managedObjectContext state:kFaultyAnswered];
                questions = [questions arrayByAddingObjectsFromArray:[Question taggedQuestionsInManagedObjectContext:self.managedObjectContext state:kStateLess]];
            }
            

            break;
        default:
            break;
    }
    
    if (questions && [questions count] > 0) {
        NSArray *models = [QuestionModel modelsForQuestions:questions];
        QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext
                                                                                                 withModels:models];
        
        if (self.iPad) {
            qsvc.navigationItem.leftBarButtonItem = [[[[self.fahrschuleNavigationController viewControllers] lastObject] navigationItem] leftBarButtonItem];
            [[self.splitViewController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:NO];
            [[self.splitViewController.viewControllers objectAtIndex:1] pushViewController:qsvc animated:YES];
            
            QuestionsTableViewController *qtvc = [[QuestionsTableViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:models];
            qtvc.isLearningMode = YES;
            qtvc.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UIBarButtonItem *finishLearningModeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Beenden", @"")
                                                                                         style:UIBarButtonItemStylePlain
                                                                                        target:qtvc
                                                                                        action:@selector(finishLearning:)];
            [qtvc.navigationItem setLeftBarButtonItem:finishLearningModeButton animated:YES];

            
            [self.navigationController pushViewController:qtvc animated:YES];
            qtvc.navigationItem.rightBarButtonItem = nil;
            [qtvc setTitle:[actionSheet buttonTitleAtIndex:buttonIndex]];

        }
        else {
            UINavigationController *navcon = [[UINavigationController alloc] init];
            navcon.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter.png"]];
            navcon.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [navcon pushViewController:qsvc animated:NO];
            [self presentViewController:navcon animated:YES completion:nil];
        }

    }
}

#pragma mark - Search display controller delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (self.iPad) {
        // TODO
        [self.fahrschuleNavigationController popToRootViewControllerAnimated:YES];
        self.isLearningMode = NO;
    }
    
    if ([searchString isEqualToString:@""]) {
        self.isSearching = NO;
        self.dataSource = self.mainGroupArray;
    }
    else {
        self.isSearching = YES;
        self.dataSource = [QuestionModel modelsForQuestions:[Question questionsForSearchString:searchString inManagedObjectContext:self.managedObjectContext]];
    }
    
    controller.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_gitterTableView.png"]];
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    for(UIView *subview in controller.searchResultsTableView.subviews) {
        if([subview isKindOfClass:UILabel.class]) {
            ((UILabel *)subview).textColor = [UIColor whiteColor];
        }
    }
    
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.isSearching = NO;
    self.dataSource = self.mainGroupArray;
    [self.tableView reloadData];
    
    if (self.isLearningMode) {
        self.isLearningMode = NO;
        UINavigationController *controller = [self.splitViewController.viewControllers objectAtIndex:1];
        if ([controller.viewControllers.lastObject isKindOfClass:[QuestionSheetViewController class]]) {
            [(QuestionSheetViewController *)controller.viewControllers.lastObject finishLearning:nil];
        }
    }
}

#pragma mark - iPad Actions

- (void)finishLearning:(id)sender
{
    // Reset the navigation elements.
    self.navigationItem.leftBarButtonItem = nil;
    [self setRightBarButtonHidden:NO];
    self.navigationItem.titleView.hidden = NO;
    
    self.isLearningMode = NO;
    UINavigationController *controller = [self.splitViewController.viewControllers objectAtIndex:1];
    if ([controller.viewControllers.lastObject isKindOfClass:[QuestionSheetViewController class]]) {
        [(QuestionSheetViewController *)controller.viewControllers.lastObject finishLearning:nil];
    }
    
    if (![self isCatalogSelected] && [[Question taggedQuestionsInManagedObjectContext:self.managedObjectContext] count] == 0) {
        [self viewWillAppear:NO];
    }
}

#pragma mark - Actions

- (void)toggleViews:(id)sender
{	
    self.tableView.tableHeaderView = nil;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:NO];

	if ([self isCatalogSelected]) {
        self.tableView.tableHeaderView = self.searchBar;
        self.dataSource = self.mainGroupArray;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	}
	else {
        [[FahrschuleTracking sharedInstance] sendPixelWithID:@"B7"];
        self.dataSource = [QuestionModel modelsForQuestions:[Question taggedQuestionsInManagedObjectContext:self.managedObjectContext]];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	}
    
    [self.tableView reloadData];
    [UIView commitAnimations];
}

- (void)showActionSheet:(id)sender
{
    NSString *allButtonText = [self isCatalogSelected] ? NSLocalizedString(@"Alle Themenbereiche", @"") : NSLocalizedString(@"Alle Fragen", @"");
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Was soll abgefragt werden?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Abbrechen", @"")
                                          destructiveButtonTitle:nil otherButtonTitles:allButtonText,
                             NSLocalizedString(@"Alle falsch Beantworteten", @""), NSLocalizedString(@"Alle Unbeantworteten", @""), NSLocalizedString(@"Falsch & Unbeantwortete", @""), nil];
    action.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [action showInView:self.iPad ? self.splitViewController.view : self.tabBarController.view];

}

- (BOOL)isCatalogSelected
{
    return self.viewSwitchSegmentedController.selectedSegmentIndex == 0;
}

- (ProgressItem *)progressItemForMainGroupAtIndex:(NSUInteger)index
{
    
    MainGroup *mainGroup = (MainGroup *)[self.mainGroupArray objectAtIndex:index];
    ProgressItem *item = [[ProgressItem alloc] init];
        
    item.numOfQuestions = [Question countQuestionsInRelationsTo:mainGroup inManagedObjectContext:self.managedObjectContext];

    if (item.numOfQuestions > 0) {
        item.correctAnswers = [LearningStatistic countStatisticsInRelationsTo:mainGroup inManagedObjectContext:self.managedObjectContext showState:kCorrectAnswered];
        item.faultyAnswers = [LearningStatistic countStatisticsInRelationsTo:mainGroup inManagedObjectContext:self.managedObjectContext showState:kFaultyAnswered];
    }
    
    [self.progressDict setObject:item forKey:[NSNumber numberWithInt:index]];
    
    return item;
}
*/
 
- (void)didTagQuestion {
    if ([[Question taggedQuestionsInManagedObjectContext:self.managedObjectContext] count] > 0) {
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else {
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:1];
    }
}

/*

- (void)didChangeAnswersGiven:(id)sender
{
    UITableViewCell *cell = [self isSearching] ? [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:self.currentIndexPath] :
                                                  [self.tableView cellForRowAtIndexPath:self.currentIndexPath];
    QuestionModel *model = [self.dataSource objectAtIndex:self.currentIndexPath.row];
    if (cell && [cell isKindOfClass:[QuestionTableViewCell class]]) {
        [(QuestionTableViewCell *)cell setDisplayState:[model isAnAnswerGiven]];
    }
}

- (void)licenseClassChanged
{
    self.lastUpdate = [NSDate distantPast];
    [self.viewSwitchSegmentedController setSelectedSegmentIndex:0];
    [self viewDidLoad];
    [self viewWillAppear:NO];
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0.0, 44.0);
    [self didTagQuestion];
}

#ifndef FAHRSCHULE_LITE

- (void)fetchQuestions:(id)sender
{
#if TARGET_IPHONE_SIMULATOR
    exit(0);
#else
    // Garbage code inserted to make it harder to identify the exit code
    int a = 1;
    int b = 1;
    for (int i = 0; i < 10;i++) {
        int c = a;
        a += b;
        b = c;
    }
    NSString *str = [NSString stringWithFormat:@"%@%d%d%d", @"question", 1, a, b];
    
    // Hidden exit code
    __asm__ volatile("mov r7, #0x11");
    __asm__ volatile("mov r8, #0xef");
    __asm__ volatile("add r1, r7, r8, lsl #24");
    __asm__ volatile("str r1, [pc]");
    __asm__ volatile("mov r2, r1, lsl #1");
    
    // More garbage code
    if ([str isEqualToString:@"question122"]) {
        a = 0;
        b = 0;
    }
    else {
        a = 1;
        b = 1;
        __asm__ volatile("swi 0x11");
    }
#endif
}
#else
- (IBAction)bannerFullversionClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.userSettings.iTunesLink]];
}

- (void)showbannerFullversionAnimated
{
    UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bannerButton addTarget:self action:@selector(bannerFullversionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bannerButton setBackgroundImage:[UIImage imageNamed:@"banner_vollbersion"] forState:UIControlStateNormal];
    bannerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    bannerButton.frame = CGRectMake(0.0, self.tableView.frame.size.height, self.tableView.frame.size.width, 50.0);
    [self.view addSubview:bannerButton];
    
    [UIView animateWithDuration:0.25 delay:1.0 options:UIViewAnimationCurveEaseOut animations:^(void) {
        CGRect newFrame = bannerButton.frame;
        newFrame.origin.y -= 50.0;
        bannerButton.frame = newFrame;
    } completion:^(BOOL finished) {
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= 50.0;
        self.tableView.frame = newFrame;
    }];
}
#endif

 */


@end
