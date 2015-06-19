//
//  ExamViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 16.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "FahrschuleViewController.h"
//#import "BarChartView.h"
#import "ExamStatistic.h"
#import "ExamArchiveViewController.h"


@interface ExamViewController : FahrschuleViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    BOOL animateViewFlip;
}

//@property (nonatomic, retain) IBOutlet BarChartView *barChartView;

@property (nonatomic, retain) IBOutlet UIView *barChartView;
@property (nonatomic, retain) UISegmentedControl *viewSwitchSegmentedController;
@property (nonatomic, retain) ExamArchiveViewController *archiveViewController;
@property (nonatomic, retain) UIBarButtonItem *showGraphButton;
@property (nonatomic, retain) IBOutlet UILabel *examDescriptionLabel;

- (void)showOldExamsTableView:(id)sender;
- (IBAction)startExam:(id)sender;
- (void)showGraph:(id)sender;
- (void)startExamWithModels:(NSArray *)models examStatistics:(ExamStatistic *)examStat;
- (void)settingsChanged;

@end
