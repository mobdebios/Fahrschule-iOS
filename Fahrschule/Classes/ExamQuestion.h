//
//  ExamQuestion.h
//  Fahrschule
//
//  Created by Johan Olsson on 21.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Question;
@class ExamStatistic;

@interface ExamQuestion :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * givenNumberAnswer;
@property (nonatomic, retain) NSNumber * tagged;
@property (nonatomic, retain) ExamStatistic * whatExam;
@property (nonatomic, retain) NSSet * givenAnswers;
@property (nonatomic, retain) Question * whatQuestion;

- (BOOL)hasAnsweredCorrectly;
- (NSUInteger)faultyPoints;

@end



