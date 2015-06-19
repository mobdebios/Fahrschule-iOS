//
//  FahrschuleViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 16.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "FahrschuleViewController.h"
#import "QuestionViewController.h"
#import "ExamResultViewController.h"


@implementation FahrschuleViewController

@synthesize managedObjectContext=_managedObjectContext;
@synthesize currentIndexPath=_currentIndexPath;

- (FahrschuleNavigationController *)fahrschuleNavigationController
{
    if (self.splitViewController) {
        UINavigationController *navcon = [self.splitViewController.viewControllers objectAtIndex:1];
        if ([navcon isKindOfClass:[FahrschuleNavigationController class]]) {
            return (FahrschuleNavigationController *)navcon;
        }
    }
    return nil;
}

- (Settings *)userSettings
{
    return [Settings sharedSettings];
}

- (BOOL)iPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.managedObjectContext = context;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil inManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.managedObjectContext = context;
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.preferredContentSize = CGSizeMake(320.0, 460.0);
    
    if ((![self isKindOfClass:[QuestionViewController class]] && ![self isKindOfClass:[ExamResultViewController class]]) || !self.userSettings.officialQuestionViewMode) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter"]];
    }
}

@end
