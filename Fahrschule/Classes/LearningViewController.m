//
//  LearningViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 16.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "LearningViewController.h"

#import "LearningStatistic.h"
#import "Question.h"
//#import "QuestionCatalogTableViewController.h"
//#import "FahrschuleTracking.h"

#import "Fahrschule-Swift.h"

@interface LearningViewController ()

@property (weak, nonatomic) IBOutlet CircularCounterView *succeedView;
@property (weak, nonatomic) IBOutlet CircularCounterView *failedView;
@property (weak, nonatomic) IBOutlet CircularCounterView *remainingView;
@property (weak, nonatomic) IBOutlet CircularChartView *chartView;


@end


@implementation LearningViewController


#pragma mark - Initialization
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureView) name:@"licenseClassChanged" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - State Save and Preservation


- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];

//    self.managedObjectContext = [[SNAppDelegate sharedDelegate] managedObjectContext];
//    [self configureView];
    
}

- (void)applicationFinishedRestoringState {
    [self.view layoutSubviews];
    [self configureView];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [[SNAppDelegate sharedDelegate] managedObjectContext];

    self.succeedView.title = NSLocalizedString(@"Richtig", nil);
    self.failedView.title = NSLocalizedString(@"Falsch", nil);
    self.remainingView.title = NSLocalizedString(@"Verbleibend", nil);
    self.chartView.subtitle = NSLocalizedString(@"beantwortet", nil);
    
    
//    if (self.iPad) {
//        [self setupKanisterView];
//        
//        self.view.autoresizingMask |= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
}

#pragma mark - Private Methods
- (void)configureView {

    // Get number of correct answered questions
    NSUInteger correctAnswer = [LearningStatistic countStatisticsInRelationsTo:nil inManagedObjectContext:self.managedObjectContext showState:kCorrectAnswered];
    self.succeedView.countLabel.text = [NSString stringWithFormat:@"%zd", correctAnswer];

    // Get number of faulty answered questions
    NSUInteger faultyAnswers = [LearningStatistic countStatisticsInRelationsTo:nil inManagedObjectContext:self.managedObjectContext showState:kFaultyAnswered];
    self.failedView.countLabel.text = [NSString stringWithFormat:@"%zd", faultyAnswers];
    
    // Get number of remaining questions
    NSUInteger totalAnswers = [Question countQuestionsInRelationsTo:nil inManagedObjectContext:self.managedObjectContext];
	NSUInteger remainingAnswers = totalAnswers - faultyAnswers - correctAnswer;
    self.remainingView.countLabel.text = [NSString stringWithFormat:@"%zd", remainingAnswers];

    // Adding values to kanister chart
    self.chartView.succeed = correctAnswer;
    self.chartView.failed = faultyAnswers;
    self.chartView.remaining = remainingAnswers;
}

#pragma mark - Navigation 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] respondsToSelector:@selector(setManagedObjectContext:)]) {
        [[segue destinationViewController] performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
    }
}

@end
