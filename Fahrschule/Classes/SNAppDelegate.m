//
//  AppDelegate.m
//  Fahrschule
//
//  Created on 12.06.15.
//  Copyright (c) 2015. All rights reserved.
//

#import "SNAppDelegate.h"

#import "Settings.h"
#import "ExamStatistic.h"

#import "Fahrschule-Swift.h"

#import <HockeySDK/HockeySDK.h>


#import <CommonCrypto/CommonDigest.h>


@interface SNAppDelegate () <UISplitViewControllerDelegate>

@end

@implementation SNAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#if !(TARGET_IPHONE_SIMULATOR)
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"be13ffc7e91b767e0cb3438bda8917f8"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
    
    [self registerDefaults];
    [Appearance customizeAppearance];
    
    Settings *settings = [Settings sharedSettings];
    if (settings.licenseClass == kUnknownLicenseClass) {
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LicenseClassSelectViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:navController animated:NO completion:^{
            NSString *title = NSLocalizedString(@"Willkomen", nil);
            NSString *msg = NSLocalizedString(@"Bitte entscheide dich für eine Führerscheinklasse. Um nachträglich die gewünschte Klasse zu ändern, rufe die Einstellungen auf. Viel Erfolg und Spaß beim Lernen!", nil);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            NSString *closeButton = NSLocalizedString(@"Schließen", nil);
            [alertController addAction:[UIAlertAction actionWithTitle:closeButton style:UIAlertActionStyleCancel handler:nil]];
            [navController presentViewController:alertController animated:NO completion:nil];
            
        }];
    }
    
    
    
    return YES;
}

- (void)registerDefaults {
    NSDictionary *defaults = @{
                               SettingsTeachingTypeKey : @(kFirstTimeLicense)
                               };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
}



#pragma mark - Split View Controller Delegate
//- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
//    return YES;
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    Settings *settings = [Settings sharedSettings];
//    if (settings.licenseClass == kUnknownLicenseClass) {
//        
//        settings.teachingType = kFirstTimeLicense;
//        
////        HelpViewController *helpViewController = [[HelpViewController alloc] init];
////        helpViewController.firstTimeView = YES;
////        [self.tabBarController presentViewController:helpViewController animated:NO completion:nil];
////        
////        UINavigationController *navcon = [[UINavigationController alloc] init];
////        LicenseClassSelectViewController *lcsvc = [[LicenseClassSelectViewController alloc] initInManagedObjectContext:self.managedObjectContext];
////        [navcon pushViewController:lcsvc animated:NO];
////        [navcon setTitle:NSLocalizedString(@"Führerscheinklasse", @"")];
////        [helpViewController presentViewController:navcon animated:NO completion:nil];
//    }
//    else if (settings.licenseClass == kLicenseClassS || settings.licenseClass == kLicenseClassM) {
////        UINavigationController *navcon = [[UINavigationController alloc] init];
////        LicenseClassSelectViewController *lcsvc = [[LicenseClassSelectViewController alloc] initInManagedObjectContext:self.managedObjectContext];
////        [navcon pushViewController:lcsvc animated:NO];
////        [navcon setTitle:NSLocalizedString(@"Führerscheinklasse", @"")];
////        [self.tabBarController presentViewController:navcon animated:NO completion:nil];
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
    [[[Settings sharedSettings] userDefaults] synchronize];
}

#pragma mark - State Preservation and Restoration
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
//    Settings *settings = [Settings sharedSettings];
//    if (settings.licenseClass == kUnknownLicenseClass) {
//        return NO;
//    } else {
//        return YES;
//        
//    }
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
//    Settings *settings = [Settings sharedSettings];
//    if (settings.licenseClass == kUnknownLicenseClass) {
//        return NO;
//    } else {
//        return YES;
//    }
}

#pragma mark - Public Methods
+ (SNAppDelegate *)sharedDelegate {
    return  (SNAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        
        Settings *settings = [Settings sharedSettings];
        if (settings.latestDatabaseVersion != settings.deviceDatabaseVersion) {
            switch (settings.deviceDatabaseVersion) {
                    /*
                     * In version 1.0.0 number questions were believed to be not correcly answered although the were.
                     * This resulted in the number of points being faulty calculated.
                     * When updating from 1.0.0 to 1.0.1 all old exams has to recalculate there number of points.
                     */
                case 20110714:
                    NSLog(@"Updating database from 1.0.0 to 1.0.1!");
                    [ExamStatistic recalculateFaultyPointsForAllExamsInManagedObjectContext:_managedObjectContext];
                case 20110815:
                case 20120806: {
#ifndef FAHRSCHULE_LITE
                    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fahrschule.sqlite"];
                    [self execuseSQLiteScript:@"new_licenseclasses_20130119" onDatabaseAtPath:storeURL];
#endif
                }
                case 20130108: {
#ifndef FAHRSCHULE_LITE
                    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fahrschule.sqlite"];
                    [self execuseSQLiteScript:@"new_questions_2013_04_01" onDatabaseAtPath:storeURL];
#endif
                    
                }
                case 20130401: {
#ifndef FAHRSCHULE_LITE
                    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fahrschule.sqlite"];
                    [self execuseSQLiteScript:@"new_questions_20131101" onDatabaseAtPath:storeURL];
#endif
                }
                    break;
            }
            settings.deviceDatabaseVersion = settings.latestDatabaseVersion;
        }
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Fahrschule" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
#ifdef FAHRSCHULE_LITE
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FahrschuleLite.sqlite"];
#else
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fahrschule.sqlite"];
#endif
    
    /**
     Copy already populated database
     */
    Settings *settings = [Settings sharedSettings];
    if (settings.deviceDatabaseVersion == 0) {
        [self copyPreloadedDatabase:storeURL overrideFileExists:NO];
        settings.deviceDatabaseVersion = settings.latestDatabaseVersion;
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        NSLog(@"Migrating database!");
        
        error = nil;
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error];
        if (error) {
            [self copyPreloadedDatabase:storeURL overrideFileExists:YES];
        }
        
        [self saveContext];
        [self addAndArchiveNewQuestions:storeURL];
        [self execuseSQLiteScript:@"new_licenseclasses_20130119" onDatabaseAtPath:storeURL];
#ifndef FAHRSCHULE_LITE
        [self execuseSQLiteScript:@"new_questions_2013_04_01" onDatabaseAtPath:storeURL];
        [self execuseSQLiteScript:@"new_questions_20131101" onDatabaseAtPath:storeURL];
#endif
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Helper methods

- (void)copyPreloadedDatabase:(NSURL *)storeURL overrideFileExists:(BOOL)override
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (override) {
        [fileManager removeItemAtPath:[storeURL path] error:nil];
    }
    
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]]) {
        NSLog(@"Copy file");
#ifdef FAHRSCHULE_LITE
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"FahrschuleLite" ofType:@"sqlite"];
#else
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Fahrschule" ofType:@"sqlite"];
#endif
        
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:NULL];
        }
    }
}

- (void)addAndArchiveNewQuestions:(NSURL *)storeURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // If the expected store doesn't exist, copy the default store.
    if ([fileManager fileExistsAtPath:[storeURL path]]) {
#ifdef FAHRSCHULE_LITE
        NSString *newQuestionsScriptPath = [[NSBundle mainBundle] pathForResource:@"lite_query" ofType:@"sql"];
#else
        NSLog(@"Adding new questions");
        NSString *newQuestionsScriptPath = [[NSBundle mainBundle] pathForResource:@"new_questions" ofType:@"sql"];
#endif
        
        if (newQuestionsScriptPath) {
            sqlite3 *databaseHandle;
            if (sqlite3_open([[storeURL path] UTF8String], &databaseHandle) == SQLITE_OK) {
                NSString *sqlScript = [NSString stringWithContentsOfFile:newQuestionsScriptPath encoding:NSUTF8StringEncoding error:NULL];
                char *error;
                if (sqlite3_exec(databaseHandle, [sqlScript UTF8String], NULL, NULL, &error) == SQLITE_OK) {
                    NSLog(@"Questions were added successfully!!!");
                }
                else {
                    NSLog(@"%@", [NSString stringWithCString:error encoding:NSUTF8StringEncoding]);
                }
                sqlite3_close(databaseHandle);
            }
        }
    }
}

- (void)execuseSQLiteScript:(NSString *)name onDatabaseAtPath:(NSURL *)storeURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // If the expected store doesn't exist, copy the default store.
    if ([fileManager fileExistsAtPath:[storeURL path]]) {
        NSLog(@"Executing script %@.sql", name);
        NSString *newQuestionsScriptPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sql"];
        
        if (newQuestionsScriptPath) {
            sqlite3 *databaseHandle;
            if (sqlite3_open([[storeURL path] UTF8String], &databaseHandle) == SQLITE_OK) {
                NSString *sqlScript = [NSString stringWithContentsOfFile:newQuestionsScriptPath encoding:NSUTF8StringEncoding error:NULL];
                char *error;
                if (sqlite3_exec(databaseHandle, [sqlScript UTF8String], NULL, NULL, &error) == SQLITE_OK) {
                    NSLog(@"Script executed successfully!");
                }
                else {
                    NSLog(@"%@", [NSString stringWithCString:error encoding:NSUTF8StringEncoding]);
                }
                sqlite3_close(databaseHandle);
            }
        }
    }
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - AdMob

// This method requires adding #import <CommonCrypto/CommonDigest.h> to your source file.
- (NSString *)hashedISU {
    NSString *result = nil;
    NSString *uuid = /*[OpenUDID value]*/ nil;
    
    if(uuid) {
        unsigned char digest[16];
        NSData *data = [uuid dataUsingEncoding:NSASCIIStringEncoding];
        CC_MD5([data bytes], (CC_LONG)[data length], digest);
        
        result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  digest[0], digest[1],
                  digest[2], digest[3],
                  digest[4], digest[5],
                  digest[6], digest[7],
                  digest[8], digest[9],
                  digest[10], digest[11],
                  digest[12], digest[13],
                  digest[14], digest[15]];
        result = [result uppercaseString];
    }
    return result;
}

- (void)reportAppOpenToAdMob {
    // Have we already reported an app open?
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"admob_app_open"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:appOpenPath]) {
        // Not yet reported -- report now
        NSString *appOpenEndpoint = [NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&md5=1&app_id=%@",
                                     [self hashedISU], @"436764243"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
        NSURLResponse *response;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
            [fileManager createFileAtPath:appOpenPath contents:nil attributes:nil]; // successful report, mark it as such
        }
    }
}



@end
