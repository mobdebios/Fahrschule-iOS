//
//  LearningResultViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 11.05.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "LearningResultViewController.h"

#import "QuestionSheetViewController.h"
#import "QuestionsTableViewController.h"
#import "LearningStatistic.h"

#ifdef FAHRSCHULE_LITE
#import "BuyFullVersionViewController.h"
#endif


@implementation LearningResultViewController

@synthesize numberOfFaultyQuestionsLabel=_numberOfFaultyQuestionsLabel;
@synthesize numberOfCorrectQuestionsLabel=_numberOfCorrectQuestionsLabel;
@synthesize topTextLabel=_topTextLabel;
@synthesize showFaultsButton=_showFaultsButton;
@synthesize questionModels=_questionModels;
@synthesize faultyQuestionModels=_faultyQuestionModels;
@synthesize questions=_questions;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withModels:(NSArray *)models
{
    self = [super initInManagedObjectContext:context];
    if (self) {
        
        NSInteger index = 0;
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        _questions = [[NSMutableArray alloc] init];
        for (QuestionModel *qm in models) {
            
            if ([qm isAnAnswerGiven]) {
                
                QuestionModel *newModel = [[QuestionModel alloc] initWithQuestion:qm.question atIndex:index++];
                newModel.givenAnswers = [NSMutableArray arrayWithArray:qm.givenAnswers];
                [mutableArray addObject:newModel];
                [self.questions addObject:newModel.question];

                
                if ([LearningStatistic addStatistics:qm.givenAnswers forQuestion:qm.question inManagedObjectContext:self.managedObjectContext] == kFaultyAnswered) {
                    numQuestionsNotCorrectAnswered++;
                }
            }
            
            // Reset question models
            qm.givenAnswers = nil;
            qm.hasSolutionBeenShown = NO;
        }
        
        if ([self.managedObjectContext hasChanges]) {
            NSError *error = nil;
            [self.managedObjectContext save:&error];
        }
        
        self.questionModels = [NSArray arrayWithArray:mutableArray];

        
        [self setTitle:NSLocalizedString(@"Ergebnis", @"")];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.autoresizingMask |= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (numQuestionsNotCorrectAnswered == 0) {
        self.showFaultsButton.enabled = NO;
    }
    
    self.numberOfFaultyQuestionsLabel.text = [NSString stringWithFormat:@"%d", numQuestionsNotCorrectAnswered];
    self.numberOfCorrectQuestionsLabel.text = [NSString stringWithFormat:@"%d", [self.questionModels count] - numQuestionsNotCorrectAnswered];
    
    if (numQuestionsNotCorrectAnswered == 0) {
        self.numberOfFaultyQuestionsLabel.textColor = [UIColor lightGrayColor];
    }
    else if ([self.questionModels count] - numQuestionsNotCorrectAnswered == 0) {
        self.numberOfCorrectQuestionsLabel.textColor = [UIColor lightGrayColor];
    }
    
    if ([self.questionModels count] == 1) {
        self.topTextLabel.text = NSLocalizedString(@"Du hast 1 Frage bearbeitet.", @"");
    }
    else {
        self.topTextLabel.text = [NSString stringWithFormat:self.topTextLabel.text, [self.questionModels count]];
    }
    
    UIBarButtonItem *closeButton = nil;
    
    if (!self.iPad) {
        closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Schließen", @"")
                                                        style:UIBarButtonItemStylePlain target:self action:@selector(closeModalView:)];
        [self.navigationItem setLeftBarButtonItem:closeButton animated:NO];
    }
    else {
        [self.navigationItem setHidesBackButton:YES];
        
        // Push a new question list only containing the questions which have been handled.
        QuestionsTableViewController *qtvc = [[QuestionsTableViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.questionModels];
        qtvc.isLearningMode = YES;
        [[self.splitViewController.viewControllers objectAtIndex:0] pushViewController:qtvc animated:YES];
        qtvc.navigationItem.rightBarButtonItem = nil;

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return self.iPad || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return self.iPad;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.iPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Actions

- (IBAction)closeModalView:(id)sender
{
#ifdef FAHRSCHULE_LITE
    BuyFullVersionViewController *bfvvc = [[BuyFullVersionViewController alloc] initWithOfficialView:NO];
    [self.navigationController pushViewController:bfvvc animated:YES];
#else
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
#endif
}

- (IBAction)examineLearningQuestions:(id)sender
{
    QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.questionModels];
    qsvc.solutionIsShown = YES;
    qsvc.showCloseButton = NO;
    
    [self.navigationController pushViewController:qsvc animated:YES];

}

- (IBAction)examinefaultyQuestions:(id)sender
{
    if (!_faultyQuestionModels) {
        NSMutableArray *models = [[NSMutableArray alloc] init];
        NSInteger index = 0;
        for (QuestionModel *model in self.questionModels) {
            if (![model hasAnsweredCorrectly]) {
                QuestionModel *newModel = [[QuestionModel alloc] initWithQuestion:model.question atIndex:index++];
                newModel.givenAnswers = [NSMutableArray arrayWithArray:model.givenAnswers];
                [models addObject:newModel];

            }
        }
        self.faultyQuestionModels = [NSArray arrayWithArray:models];

    }
    
    QuestionSheetViewController *qsvc = [[QuestionSheetViewController alloc] initInManagedObjectContext:self.managedObjectContext withModels:self.faultyQuestionModels];
    qsvc.solutionIsShown = YES;
    qsvc.showCloseButton = NO;
    
    [self.navigationController pushViewController:qsvc animated:YES];

}

@end
