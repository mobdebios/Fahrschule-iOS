//
//  FahrschuleNavigationController.h
//  Fahrschule
//
//  Created by Johan Olsson on 21.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FahrschuleNavigationController : UINavigationController <UISplitViewControllerDelegate> {
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// iPad
@property (nonatomic, retain) UIPopoverController *popoverController;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
