//
//  AppDelegate.h
//  Fahrschule
//
//  Created by Alexandr Zhovty on 12.06.15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define DEIVECE_IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define DEIVECE_IS_IPHONE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone



@interface SNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (SNAppDelegate *)sharedDelegate;


@end

