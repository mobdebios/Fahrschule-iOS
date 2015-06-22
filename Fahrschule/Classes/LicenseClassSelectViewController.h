//
//  LicenseClassSelectViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 20.04.11.
//  Copyright 2011 freenet. All rights reserved.
//




@interface LicenseClassSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, retain) NSDictionary *licenseClassesDict;
@property (nonatomic, retain) NSArray *keyList;
@property (nonatomic, retain) UITableView *tableView;

- (void)closeModalView:(id)sender;

@end
