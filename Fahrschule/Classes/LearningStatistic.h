//
//  LearningStatistic.h
//  Fahrschule
//
//  Created by Johan Olsson on 17.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Answer;
@class Question;

typedef NS_ENUM(NSInteger, StatisticState) {
    kCorrectAnswered = 0,
    kFaultyAnswered = 1,
    kNotAnswered = 2,
    kStateLess = 4
};


@interface LearningStatistic :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * licenseClass;
@property (nonatomic, retain) Question * whatQuestion;
@property (nonatomic, retain) NSNumber * state;

+ (NSArray *)statisticsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context showState:(StatisticState)state;
+ (NSUInteger)countStatisticsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context showState:(StatisticState)state;
+ (StatisticState)addStatistics:(NSArray *)givenAnswers forQuestion:(Question *)question inManagedObjectContext:(NSManagedObjectContext *)context;
+ (LearningStatistic *)latestStatistic:(NSManagedObjectContext *)context;
+ (void)statisticsResetInManagedObjectContext:(NSManagedObjectContext *)context;

@end