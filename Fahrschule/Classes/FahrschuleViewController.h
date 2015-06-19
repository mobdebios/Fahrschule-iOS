//
//  FahrschuleViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 16.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "FahrschuleNavigationController.h"


@interface FahrschuleViewController : UIViewController {
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) Settings *userSettings;

/*
 * iPad
 */
@property (nonatomic, readonly) BOOL iPad;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;
@property (nonatomic, readonly) FahrschuleNavigationController *fahrschuleNavigationController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initWithNibName:(NSString *)nibNameOrNil inManagedObjectContext:(NSManagedObjectContext *)context;

@end
