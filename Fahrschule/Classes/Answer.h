//
//  Answer.h
//  Fahrschule
//
//  Created by Johan Olsson on 17.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Question;

@interface Answer :  NSManagedObject  
{
    
}

@property (nonatomic, retain) NSNumber * correct;
@property (nonatomic, retain) NSNumber * correctNumber;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Question * whatQuestion;
@property (nonatomic, retain) NSSet * whatExamQuestions;
@property (nonatomic, assign) BOOL selected;

@end