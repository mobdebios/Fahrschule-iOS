//
//  QuestionTags.m
//  Fahrschule
//
//  Created by Johan Olsson on 29.04.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

#import "QuestionTags.h"
#import "Question.h"
#import "Settings.h"


@implementation QuestionTags

+ (void)setTagged:(BOOL)tagged forQuestion:(Question *)question inManagedObjectContext:(NSManagedObjectContext *)context
{
    Settings *settings = [Settings sharedSettings];
    QuestionTags *tag = [[[[question whatTags] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"licenseClass = %d", settings.licenseClass]] allObjects] lastObject];
    
    if (!tag) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"QuestionTags" inManagedObjectContext:context];
        tag.licenseClass = [NSNumber numberWithInt:settings.licenseClass];
        tag.whatQuestion = question;
    }
    else {
        [context deleteObject:tag];
    }
    
    [[[Settings sharedSettings] userDefaults] synchronize];
}

+ (BOOL)isQuestionTagged:(Question *)question
{
    Settings *settings = [Settings sharedSettings];
    NSSet *filteredSet = [[question whatTags] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"licenseClass = %d", settings.licenseClass]];
    
    return [filteredSet count] > 0;
}

@dynamic licenseClass;
@dynamic whatQuestion;

@end
