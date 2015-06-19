//
//  QuestionTags.h
//  Fahrschule
//
//  Created by Johan Olsson on 29.04.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface QuestionTags : NSManagedObject

@property (nonatomic, retain) NSNumber * licenseClass;
@property (nonatomic, retain) Question * whatQuestion;

+ (void)setTagged:(BOOL)tagged forQuestion:(Question *)question inManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)isQuestionTagged:(Question *)question;

@end
