//
//  ExamArchiveViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 16.12.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

//#import "FahrschuleTableViewController.h"

//@interface ExamArchiveViewController : FahrschuleTableViewController

@interface ExamArchiveViewController : UIViewController

/*
 * iPad
 */
@property (nonatomic, retain) UIViewController *detailView;
@property (nonatomic, retain) UIViewController *examViewController;
@property (nonatomic, retain) UILabel *emptyArchiveTableViewLabel;

@end
