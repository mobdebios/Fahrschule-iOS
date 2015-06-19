//
//  QuestionCatalogTableViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 17.03.11.
//  Copyright 2011 freenet. All rights reserved.
//



@interface QuestionCatalogTableViewControllerOld : UIViewController



@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;






@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSMutableDictionary *progressDict;
@property (nonatomic, retain) NSArray *mainGroupArray;

// iPad

@property (nonatomic, assign) BOOL isLearningMode;

- (void)toggleViews:(id)sender;
//- (ProgressItem *)progressItemForMainGroupAtIndex:(NSUInteger)index;
- (void)licenseClassChanged;
- (void)finishLearning:(id)sender;
//- (void)didTagQuestion;
- (void)didChangeAnswersGiven:(id)sender;

#ifdef FAHRSCHULE_LITE
- (void)showbannerFullversionAnimated;
#endif

@end
