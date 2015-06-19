//
//  LearningResultViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 11.05.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "FahrschuleViewController.h"


@interface LearningResultViewController : FahrschuleViewController {
    NSInteger numQuestionsNotCorrectAnswered;
}

@property (nonatomic, retain) IBOutlet UILabel *numberOfFaultyQuestionsLabel;
@property (nonatomic, retain) IBOutlet UILabel *numberOfCorrectQuestionsLabel;
@property (nonatomic, retain) IBOutlet UILabel *topTextLabel;
@property (nonatomic, retain) IBOutlet UIButton *showFaultsButton;
@property (nonatomic, retain) NSArray *questionModels;
@property (nonatomic, retain) NSArray *faultyQuestionModels;

// iPad

@property (nonatomic, retain) NSMutableArray *questions;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withModels:(NSArray *)models;
- (IBAction)closeModalView:(id)sender;
- (IBAction)examineLearningQuestions:(id)sender;
- (IBAction)examinefaultyQuestions:(id)sender;

@end
