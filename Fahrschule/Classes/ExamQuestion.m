// 
//  ExamQuestion.m
//  Fahrschule
//
//  Created by Johan Olsson on 21.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "ExamQuestion.h"

#import "Answer.h"
#import "ExamStatistic.h"
#import "Question.h"

@implementation ExamQuestion 

@dynamic order;
@dynamic givenNumberAnswer;
@dynamic tagged;
@dynamic whatExam;
@dynamic givenAnswers;
@dynamic whatQuestion;

- (BOOL)hasAnsweredCorrectly
{
    BOOL correct;
    if ([self.whatQuestion.type isEqualToString:@"number"]) {
        correct = [self.whatQuestion answerState:[NSArray arrayWithObject:self.givenNumberAnswer]] == kCorrectAnswered ? YES : NO;
    }
    else {
        correct = [self.whatQuestion answerState:[self.givenAnswers allObjects]] == kCorrectAnswered ? YES : NO;
    }
    
    return correct;
}

- (NSUInteger)faultyPoints
{
    NSUInteger points = 0;
    
    if (![self hasAnsweredCorrectly]) {
        points = [self.whatQuestion.points intValue];
    }
    
    return points;
}

@end
