//
//  QuestionModel.h
//  Fahrschule
//
//  Created by Johan Olsson on 17.03.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"

@interface QuestionModel : NSObject {
    
}

@property (nonatomic, retain) Question *question;
@property (nonatomic, retain) NSMutableArray *givenAnswers;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) QuestionType questionType;
@property (nonatomic, assign) BOOL hasSolutionBeenShown;
@property (nonatomic, assign) NSUInteger numGivenAnswers;
@property (nonatomic, assign) BOOL isTagged;

- (id)initWithQuestion:(Question *)question atIndex:(NSInteger)index;
+ (NSArray *)modelsForQuestions:(NSArray *)questions;
- (BOOL)hasAnsweredCorrectly;
- (BOOL)isAnAnswerGiven;

@end
