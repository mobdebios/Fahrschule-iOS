//
//  ExamResultViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 21.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "FahrschuleViewController.h"


@interface ExamResultViewController : FahrschuleViewController {
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) Settings *userSettings;
@property (nonatomic, retain) IBOutlet UILabel *numberOfFaultsLabel;
@property (nonatomic, retain) IBOutlet UILabel *handinTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *mascotFeedbackLabel;
@property (nonatomic, retain) IBOutlet UIImageView *mascotImageView;
@property (nonatomic, retain) IBOutlet UIButton *showFaultsButton;
@property (nonatomic, assign) NSInteger timeLeft;
@property (nonatomic, assign) NSInteger maxPoints;

@property (nonatomic, retain) NSArray *questionModels;
@property (nonatomic, retain) NSArray *faultyQuestionModels;

/**
 * Official exam layout properies
 */
@property (nonatomic, readonly) UIColor *correctColor;
@property (nonatomic, readonly) UIColor *incorrectColor;
@property (nonatomic, readonly) UIColor *titleBackgrondColor;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withModels:(NSArray *)models;
- (IBAction)closeModalView:(id)sender;
- (IBAction)retryPreviousExam:(id)sender;
- (IBAction)examineExam:(id)sender;
- (IBAction)examinefaultyQuestions:(id)sender;
- (NSString *)handinTimeString;
- (IBAction)questionSelected:(id)sender;

@end
