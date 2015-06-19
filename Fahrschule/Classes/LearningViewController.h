//
//  LearningViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 16.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

//#import "FahrschuleViewController.h"
//#import "KanisterView.h"

#import <UIKit/UIKit.h>

@class Settings;

@interface LearningViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, readonly) Settings *userSettings;

@end
