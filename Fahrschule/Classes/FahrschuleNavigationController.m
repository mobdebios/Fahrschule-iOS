//
//  FahrschuleNavigationController.m
//  Fahrschule
//
//  Created by Johan Olsson on 21.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "FahrschuleNavigationController.h"
#import "TimerBarButtonView.h"
#import "IntelligentSplitViewController.h"


@implementation FahrschuleNavigationController

@synthesize managedObjectContext=_managedObjectContext;
@synthesize popoverController=__popoverController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"QuestionSheetViewController" bundle:nil];
    if (self) {
        self.managedObjectContext = context;
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // If a memory warning occurs. The left bar buttons are released and needs to be re-created. This will force the buttons to re-create fooling
    // the split view controller that a rotation did just occur.
    if (self.splitViewController && UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) && !self.navigationItem.leftBarButtonItem) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:orientation] forKey:UIApplicationStatusBarOrientationUserInfoKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillChangeStatusBarOrientationNotification object:self userInfo:dict];
        
    }
    
    
    self.navigationBar.translucent = NO;
}

#pragma mark - Split view controller delegate

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    for (UIViewController *vc in self.viewControllers) {
        vc.navigationItem.leftBarButtonItem = nil;
    }
    self.popoverController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    NSString *title = [[((UINavigationController *)aViewController).viewControllers lastObject] title];
    barButtonItem.title = [title isEqualToString:NSLocalizedString(@"Prüfungsfragen", @"")] ? title : barButtonItem.title;
    for (UIViewController *vc in self.viewControllers) {
        vc.navigationItem.leftBarButtonItem = barButtonItem;
    }
    self.popoverController = pc;
}

@end
