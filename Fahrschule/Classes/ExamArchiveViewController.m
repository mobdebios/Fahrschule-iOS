//
//  ExamArchiveViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 16.12.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

#import "ExamArchiveViewController.h"
//#import "ProgressTableViewCell.h"
#import "ExamStatistic.h"
//#import "QuestionSheetViewController.h"
//#import "OfficialExamNavigationController.h"


@implementation ExamArchiveViewController


//- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
//{
//    self = [super initInManagedObjectContext:context];
//    if (self) {
//        self.dataSource = [ExamStatistic statisticsInManagedObjectContext:self.managedObjectContext fetchLimit:0];
//        
//        [self setTitle:NSLocalizedString(@"Archiv", @"")];
//        
//        if (self.iPad) {
//            _emptyArchiveTableViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 80.0, 310.0, 50.0)];
//            self.emptyArchiveTableViewLabel.textColor = [UIColor whiteColor];
//            self.emptyArchiveTableViewLabel.backgroundColor = [UIColor clearColor];
//            self.emptyArchiveTableViewLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            self.emptyArchiveTableViewLabel.numberOfLines = 3;
//            self.emptyArchiveTableViewLabel.textAlignment = NSTextAlignmentCenter;
//            self.emptyArchiveTableViewLabel.font = [UIFont boldSystemFontOfSize:18.0];
//            self.emptyArchiveTableViewLabel.text = NSLocalizedString(@"Aktuell befinden sich noch keine Prüfungen im Archiv.", @"");
//        }
//    }
//    return self;
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.iPad) {
        [self.view addSubview:self.emptyArchiveTableViewLabel];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.iPad) {
        self.emptyArchiveTableViewLabel.hidden = [self.dataSource count] > 0;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ProgressTableViewCell *cell = (ProgressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ProgressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ExamStatistic *exam = (ExamStatistic *)[self.dataSource objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd. MMM yyyy HH:mm"];
    
    NSString *image = [exam hasPassed] ? @"icon_richtig.png" : @"icon_falsch.png";
    cell.imageView.image = [UIImage imageNamed:image];
    cell.primaryLabel.text = [NSString stringWithFormat:@"%@ - %d Pkt.", [formatter stringFromDate:exam.date], [exam.faultyPoints intValue]];
    cell.primaryLabel.frame = CGRectMake(44.0, 0.0, 244.0, 44.0);

    
    cell.progressView.hidden = YES;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExamStatistic *exam = (ExamStatistic *)[self.dataSource objectAtIndex:indexPath.row];
    QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:[exam questionModelsForExam]];
    qsvc.isExam = YES;
    qsvc.isOfficialLayout = self.userSettings.officialQuestionViewMode;
    qsvc.solutionIsShown = YES;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.iPad && !self.userSettings.officialQuestionViewMode) {
        qsvc.navigationItem.leftBarButtonItem = self.detailView.navigationItem.leftBarButtonItem;
        
        QuestionsTableViewController *qtvc = [[QuestionsTableViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:exam.questionModelsForExam];
        qtvc.isExamHistory = YES;
        [qtvc setRightBarButtonHidden:YES];
        qtvc.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.navigationController pushViewController:qtvc animated:YES];
        qtvc.title = NSLocalizedString(@"Prüfungsfragen", @"");
        [self.detailView.navigationController pushViewController:qsvc animated:YES];
        
        [self.fahrschuleNavigationController.popoverController dismissPopoverAnimated:YES];
    }
    else {
        // Lock orientation to portrait to prevent tab view controller to change it's orientation while doing the exam.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lockPortraitOrientation" object:nil];
        
        UINavigationController *navcon = self.userSettings.officialQuestionViewMode ? [[OfficialExamNavigationController alloc] init] : [[UINavigationController alloc] init];
        navcon.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter.png"]];
        navcon.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [navcon pushViewController:qsvc animated:NO];
        
        if (self.iPad) {
            [self.fahrschuleNavigationController.tabBarController presentViewController:navcon animated:YES completion:nil];
        }
        else {
            [self.examViewController presentViewController:navcon animated:YES completion:nil];
        }
    }
}
 */

@end
