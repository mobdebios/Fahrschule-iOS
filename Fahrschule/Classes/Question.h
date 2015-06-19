//
//  Question.h
//  Fahrschule
//
//  Created by Johan Olsson on 21.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "LearningStatistic.h"

//typedef enum {
//    kChoiceQuestion = 1,
//    kNumberQuestion = 2
//} QuestionType;

typedef NS_ENUM(NSUInteger, QuestionType) {
    kChoiceQuestion = 1,
    kNumberQuestion = 2
};

@class Answer;
@class SubGroup;

@interface Question :  NSManagedObject  
{
    NSSet * _rearrangedChoices;
}

@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSSet * whatTags;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSNumber * licenseClassFlag;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet * learnStats;
@property (nonatomic, retain) SubGroup * containedIn;
@property (nonatomic, retain) NSSet * choices;
@property (nonatomic, retain) NSSet * whatExamQuestions;
@property (nonatomic, readonly) NSSet * rearrangedChoices;
@property (nonatomic, retain) NSNumber * deleted;

+ (NSArray *)questionsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)questionsInRelationsTo:(id)object state:(StatisticState)state inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countQuestionsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)questionsForSearchString:(NSString *)searchString inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)examQuestionsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)taggedQuestionsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)taggedQuestionsInManagedObjectContext:(NSManagedObjectContext *)context state:(StatisticState)state;
- (StatisticState)answerState:(NSArray *)answers;
- (void)setTagged:(BOOL)tagged inManagedObjectContext:(NSManagedObjectContext *)context;
- (BOOL)isQuestionTagged;
- (QuestionType)whatType;

@end


@interface Question (CoreDataGeneratedAccessors)
- (void)addPrevAnswersObject:(LearningStatistic *)value;
- (void)removePrevAnswersObject:(LearningStatistic *)value;
- (void)addPrevAnswers:(NSSet *)value;
- (void)removePrevAnswers:(NSSet *)value;

- (void)addChoicesObject:(Answer *)value;
- (void)removeChoicesObject:(Answer *)value;
- (void)addChoices:(NSSet *)value;
- (void)removeChoices:(NSSet *)value;

@end

