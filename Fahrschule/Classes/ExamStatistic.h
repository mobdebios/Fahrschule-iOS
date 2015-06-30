//
//  ExamStatistic.h
//  Fahrschule
//
//  Created by Johan Olsson on 18.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <sqlite3.h>

@class QuestionModel;


typedef NS_ENUM(NSInteger, ExamState) {
    kFinishedExam = 0,
    kCanceledExam = 1,
    kStateLessExam = 2
};

@interface ExamStatistic :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * faultyPoints;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * licenseClass;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * teachingType;
@property (nonatomic, retain) NSNumber * timeLeft;
@property (nonatomic, retain) NSSet * whatQuestions;

+ (void)recalculateFaultyPointsForAllExamsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (ExamStatistic *)insertNewStatistics:(NSManagedObjectContext *)context state:(ExamState)state;
+ (NSArray *)datesForMonthIndicators:(NSManagedObjectContext *)context;
+ (NSArray *)statisticsInManagedObjectContext:(NSManagedObjectContext *)context fetchLimit:(int)limit;
+ (NSArray *)statisticsInManagedObjectContext:(NSManagedObjectContext *)context fetchLimit:(int)limit state:(ExamState)state;
- (NSArray *)questionModelsForExam;
- (NSArray *)questionsForExam;
- (void)deleteExamInManagedObjectContext:(NSManagedObjectContext *)context;
- (void)addStatisticsWithModel:(QuestionModel *)model inManagedObjectContext:(NSManagedObjectContext *)context;
- (NSUInteger)numberOfFaultyAnsweredQuestions;
- (BOOL)hasPassed;

@end