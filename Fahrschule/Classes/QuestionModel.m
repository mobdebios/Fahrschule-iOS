//
//  QuestionModel.m
//  Fahrschule
//
//  Created by Johan Olsson on 17.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "QuestionModel.h"
#import "Answer.h"



@implementation QuestionModel

@synthesize question=_question;
@synthesize givenAnswers=_givenAnswers;
@synthesize index=_index;
@synthesize questionType=_questionType;
@synthesize hasSolutionBeenShown=_hasSolutionBeenShown;
@synthesize numGivenAnswers=_numGivenAnswers;
@synthesize isTagged=_isTagged;

- (NSMutableArray *)givenAnswers
{
	if (!_givenAnswers) {
		_givenAnswers = [[NSMutableArray alloc] init];
        if (self.questionType == kNumberQuestion) {
            [_givenAnswers addObject:[NSNumber numberWithInt:-1]];
        }
        
        if ([self.question.number isEqualToString:@"11.11.1"]) {
            [_givenAnswers addObject:[NSNumber numberWithInt:-1]];
        }
	}
	
	return _givenAnswers;
}

#pragma mark - Initialization

- (id)initWithQuestion:(Question *)question atIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        self.question = question;
        self.index = index;
        self.hasSolutionBeenShown = NO;
        self.numGivenAnswers = 0;
        self.questionType = [question.type isEqualToString:@"number"] ? kNumberQuestion : kChoiceQuestion;
        self.isTagged = NO;
    }
    
    return self;
}

- (BOOL)hasAnsweredCorrectly
{
    return [self.question answerState:self.givenAnswers] == kCorrectAnswered ? YES : NO;
}

- (BOOL)isAnAnswerGiven
{
    if (self.questionType == kNumberQuestion) {
        NSNumber *answer = (NSNumber *)[self.givenAnswers objectAtIndex:0];
        BOOL result = [answer integerValue] != -1 ? YES : NO;
        
        if ([self.question.number isEqualToString:@"11.11.1"] && !result) {
            answer = (NSNumber *)[self.givenAnswers objectAtIndex:1];
            result = [answer integerValue] != -1 ? YES : NO;
        }
        
        return result;
    }
    
    return [self.givenAnswers count] > 0;
}

+ (NSArray *)modelsForQuestions:(NSArray *)questions
{

    NSMutableArray *modelsMArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [questions count]; i++) {
        Question *q = (Question *)[questions objectAtIndex:i];
        QuestionModel *model = [[QuestionModel alloc] initWithQuestion:q atIndex:i];
        [modelsMArray addObject:model];

    }

    return [NSArray arrayWithArray:modelsMArray];
}

@end
