// 
//  Question.m
//  Fahrschule
//
//  Created by Johan Olsson on 21.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#define ARC4RANDOM_MAX 0x100000000

#import "Question.h"

#import "Answer.h"
#import "Settings.h"
#import "MainGroup.h"
#import "SubGroup.h"
#import "QuestionTags.h"
#import "NSArray+shuffleArray.h"

@interface Question (hidden)

+ (NSArray *)questionsInRelationsTo:(id)object limit:(NSUInteger)limit numberOfImageQuestions:(NSUInteger)numImageQuestions sumPoints:(NSUInteger)sumPoints context:(NSManagedObjectContext *)context;
+ (NSArray *)numberOfAdditionalQuestions:(NSUInteger)limit sumPoints:(NSUInteger)sumPoints context:(NSManagedObjectContext *)context;

@end

@implementation Question (hidden)

+ (NSArray *)questionsInRelationsTo:(id)object limit:(NSUInteger)limit numberOfImageQuestions:(NSUInteger)numImageQuestions sumPoints:(NSUInteger)sumPoints context:(NSManagedObjectContext *)context
{
    Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
    if ([object isKindOfClass:[MainGroup class]]) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"containedIn.containedIn = %@ AND (licenseClassFlag & %d) > 0 AND containedIn.containedIn.baseMaterial = 1 AND deleted = 0",
                               ((MainGroup *)object), settings.licenseClass]];
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"containedIn.containedIn IN(%@) AND (licenseClassFlag & %d) > 0 AND containedIn.containedIn.baseMaterial = 1 AND deleted = 0",
                               ((NSArray *)object), settings.licenseClass]];
    }
    
    NSError *error = nil;
    NSMutableArray *questionPool = [NSMutableArray arrayWithArray:[context executeFetchRequest:request error:&error]];
    NSMutableArray *examQuestions = [[NSMutableArray alloc] init];
    
    if (!error) {
        NSUInteger lowestPoint = [((Question *)[questionPool objectAtIndex:0]).points integerValue];
        NSInteger pointsLeft;
        NSUInteger numAddedImageQuestions;
        
        do {
            // Initialize the start values.
            pointsLeft = sumPoints;
            numAddedImageQuestions = 0;
            [questionPool addObjectsFromArray:examQuestions];
            [examQuestions removeAllObjects];
            
            for (NSUInteger i = 0; i < limit; i++) {
                
                // Get random index to use when fetching a random question
                int n = (arc4random() % [questionPool count]);
                
                // Get a random question from the question pool
                Question *question = [questionPool objectAtIndex:n];
                
                if (([question.points integerValue] > pointsLeft && pointsLeft != 0) || (pointsLeft - [question.points integerValue] < lowestPoint && pointsLeft - [question.points integerValue] != 0)) {
                    // A question was fetched where the question points is larger than the number of points left to fetch. Ex. we need 4 more points to reach our point sum but the question
                    // fetched had a value of 5.
                    
                    // Alternative if we by adding this question to our exam question will reach a lower pointsLeft than the question with the lowest point. Ex. we need 6 more points and the
                    // question fetched had a value of 5. After adding the question we would have a pointLeft variable with the value 1 which migth be smaller than our lowestPoint.
                    // The single case where a lower pointsLeft is accepted is when it is 0.
                    i--;
                }
                else {
                    pointsLeft -= [question.points integerValue];
                    
                    // Add selected question to exam questions
                    [examQuestions addObject:question];
                    
                    // We must keep track of the amount of image questions since for certain exams some categories require a certain amount of image questions.
                    if (question.image) {
                        numAddedImageQuestions++;
                    }
                    
                    // The added question is removed from the pool. We don't want to add it more than once.
                    [questionPool removeObjectAtIndex:n];
                    
                    if (pointsLeft == 0) {
                        break;
                    }
                }
            }
            
            // Make sure pointsLeft is 0 and that we have reached the given amount of total and image questions. Otherwise we start over.
        } while (pointsLeft != 0 || [examQuestions count] != limit || numAddedImageQuestions < numImageQuestions);
    }
    
    return [NSArray arrayWithArray:examQuestions];
}

+ (NSArray *)numberOfAdditionalQuestions:(NSUInteger)limit sumPoints:(NSUInteger)sumPoints context:(NSManagedObjectContext *)context
{
    Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
    [request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn.containedIn.baseMaterial = 0 AND deleted = 0", settings.licenseClass]];
    
    NSError *error = nil;
    NSMutableArray *questionPool = [NSMutableArray arrayWithArray:[context executeFetchRequest:request error:&error]];
    NSMutableArray *examQuestions = [[NSMutableArray alloc] init];
    
    if (!error) {
        NSUInteger lowestPoint = [((Question *)[questionPool objectAtIndex:0]).points integerValue];
        NSInteger pointsLeft;
        
        do {
            // Initialize the start values.
            pointsLeft = sumPoints;
            [questionPool addObjectsFromArray:examQuestions];
            [examQuestions removeAllObjects];
            
            for (NSUInteger i = 0; i < limit; i++) {
                
                // Get random index to use when fetching a random question
                int n = (arc4random() % [questionPool count]);
                
                // Get a random question from the question pool
                Question *question = [questionPool objectAtIndex:n];
                
                if (([question.points integerValue] > pointsLeft && pointsLeft != 0) || (pointsLeft - [question.points integerValue] < lowestPoint && pointsLeft - [question.points integerValue] != 0)) {
                    // A question was fetched where the question points is larger than the number of points left to fetch. Ex. we need 4 more points to reach our point sum but the question
                    // fetched had a value of 5.
                    
                    // Alternative if we by adding this question to our exam question will reach a lower pointsLeft than the question with the lowest point. Ex. we need 6 more points and the
                    // question fetched had a value of 5. After adding the question we would have a pointLeft variable with the value 1 which might be smaller than our lowestPoint.
                    // The single case where a lower pointsLeft is accepted is when it is 0.
                    i--;
                }
                else {
                    pointsLeft -= [question.points integerValue];
                    
                    // Add selected question to exam questions
                    [examQuestions addObject:question];
                    
                    // The added question is removed from the pool. We don't want to add it more than once.
                    [questionPool removeObjectAtIndex:n];
                    
                    if (pointsLeft == 0) {
                        break;
                    }
                }
            }
            
            // Make sure pointsLeft is 0 and that we have reached the given amount of total questions. Otherwise we start over.
        } while (pointsLeft != 0 || [examQuestions count] != limit);
    }
    
    return [NSArray arrayWithArray:examQuestions];
}

@end

@implementation Question 

+ (NSArray *)questionsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context
{	
	Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
	if ([object isKindOfClass:[MainGroup class]]) {
		[request setPredicate:[NSPredicate
			predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn IN(%@) AND deleted = 0",
                               settings.licenseClass, ((MainGroup *)object).contains]];
	}
	else if ([object isKindOfClass:[SubGroup class]]) {
		[request setPredicate:[NSPredicate
			predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn = %@ AND deleted = 0",
                               settings.licenseClass, (SubGroup *)object]];
	}
	else {
		[request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND deleted = 0", settings.licenseClass]];
	}
    
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}

+ (NSUInteger)countQuestionsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context
{
    Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
    
    if ([object isKindOfClass:[MainGroup class]]) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn.containedIn = %@ AND deleted = 0",
                               settings.licenseClass, ((MainGroup *)object)]];
	}
	else if ([object isKindOfClass:[SubGroup class]]) {
		[request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn = %@ AND deleted = 0",
                               settings.licenseClass, (SubGroup *)object]];
	}
	else {
		[request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND deleted = 0",
                               settings.licenseClass]];
	}
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    return error == nil ? count : 0;
}

+ (NSArray *)questionsInRelationsTo:(id)object state:(StatisticState)state inManagedObjectContext:(NSManagedObjectContext *)context
{
    Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
	
    if (state == kStateLess) {
        if ([object isKindOfClass:[MainGroup class]]) {
            [request setPredicate:[NSPredicate
                                   predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn.containedIn = %@ AND ANY learnStats = nil AND deleted = 0",
                                   settings.licenseClass, (MainGroup *)object]];
        }
        else if ([object isKindOfClass:[SubGroup class]]) {
            [request setPredicate:[NSPredicate
                                   predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn = %@ AND ANY learnStats = nil AND deleted = 0",
                                   settings.licenseClass, (SubGroup *)object]];
        }
        else {
            [request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND ANY learnStats = nil AND deleted = 0",
                                   settings.licenseClass]];
        }
    }
    else {
        if ([object isKindOfClass:[MainGroup class]]) {
            [request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn.containedIn = %@ AND deleted = 0", settings.licenseClass, (MainGroup *)object]];
        }
        else if ([object isKindOfClass:[SubGroup class]]) {
            [request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND containedIn = %@ AND deleted = 0", settings.licenseClass, (SubGroup *)object]];
        }
        else {
            [request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND deleted = 0", settings.licenseClass]];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        NSError *error = nil;
        NSArray *result = [[context executeFetchRequest:request error:&error] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        return [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY learnStats.licenseClass = %d AND ALL learnStats.state = %d", settings.licenseClass, state]];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSError *error = nil;
    return [[context executeFetchRequest:request error:&error] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

+ (NSArray *)questionsForSearchString:(NSString *)searchString inManagedObjectContext:(NSManagedObjectContext *)context
{
    if ([searchString isEqualToString:@""] || searchString == nil) return [NSArray arrayWithObjects:nil];
    
    Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"(licenseClassFlag & %d) > 0 AND (text like[c] %@ OR number like[c] %@) AND deleted = 0",
                           settings.licenseClass, [NSString stringWithFormat:@"*%@*", searchString], [NSString stringWithFormat:@"*%@*", searchString]]];
    
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}

+ (NSArray *)examQuestionsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *examQuestions = [[NSMutableArray alloc] init];
    
#ifdef FAHRSCHULE_LITE
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
    
    NSArray *inArray = [NSArray arrayWithObjects:@"6.1.1", @"1.1.7", @"2.3.2", @"1.1.3", @"2.2.37", @"3.1.22", @"6.3.16", @"2.5.4", @"4.8.14", @"11.21.6", nil];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"number IN %@", inArray]];
    
    NSError *error = nil;
    NSArray *questions = [context executeFetchRequest:request error:&error];
    if (!error) {
        [examQuestions addObjectsFromArray:questions];
    }
#else
    Settings *settings = [Settings sharedSettings];
    NSArray *mainGroups = [MainGroup mainGroupsInManagedObjectContext:context];

    NSDictionary *examSheetDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ExamSheet" ofType:@"plist"]];
    examSheetDictionary = [examSheetDictionary objectForKey:[NSString stringWithFormat:@"%zd", settings.licenseClass]];
    examSheetDictionary = [examSheetDictionary objectForKey:[NSString stringWithFormat:@"%zd", settings.teachingType]];
    
    for (MainGroup *mainGroup in mainGroups) {
        if ([examSheetDictionary objectForKey:mainGroup.name] && [mainGroup.baseMaterial boolValue]) {
            NSDictionary *tmpDict = [examSheetDictionary objectForKey:mainGroup.name];
            [examQuestions addObjectsFromArray:[Question questionsInRelationsTo:mainGroup limit:[((NSNumber *)[tmpDict objectForKey:@"totalquestions"]) intValue]
                                                         numberOfImageQuestions:[((NSNumber *)[tmpDict objectForKey:@"imagequestions"]) intValue]
                                                                      sumPoints:[((NSNumber *)[tmpDict objectForKey:@"points"]) intValue] context:context]];
        }
    }
    
    if (settings.licenseClass == kLicenseClassMOFA) {
        NSMutableArray *mainGroupsArray = [[NSMutableArray alloc] init];
        NSArray *tmp = [NSArray arrayWithObjects:@"Verkehrszeichen", @"Technik", @"Eignung und Befähigung von Kraftfahrern", nil];
        for (MainGroup *mainGroup in mainGroups) {
            if ([tmp containsObject:mainGroup.name] && [mainGroup.baseMaterial boolValue]) {
                [mainGroupsArray addObject:mainGroup];
            }
        }
        NSDictionary *tmpDict = [examSheetDictionary objectForKey:@"MOFA"];
        [examQuestions addObjectsFromArray:[Question questionsInRelationsTo:mainGroupsArray limit:[((NSNumber *)[tmpDict objectForKey:@"totalquestions"]) intValue]
                                                     numberOfImageQuestions:[((NSNumber *)[tmpDict objectForKey:@"imagequestions"]) intValue]
                                                                  sumPoints:[((NSNumber *)[tmpDict objectForKey:@"points"]) intValue] context:context]];
    }
    
    NSDictionary *tmpDict = [examSheetDictionary objectForKey:@"Zusatzstoff"];
    [examQuestions addObjectsFromArray:[Question numberOfAdditionalQuestions:[[tmpDict objectForKey:@"totalquestions"] intValue]
                                                                   sumPoints:[[tmpDict objectForKey:@"points"] intValue] context:context]];
    
#endif
    
    return examQuestions;
}

+ (NSArray *)taggedQuestionsInManagedObjectContext:(NSManagedObjectContext *)context
{
    
    Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Question" inManagedObjectContext:context]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"ANY whatTags.licenseClass = %d AND deleted = 0", settings.licenseClass]];
    
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}

+ (NSArray *)taggedQuestionsInManagedObjectContext:(NSManagedObjectContext *)context state:(StatisticState)state
{
    NSArray *taggedQuestions = [Question taggedQuestionsInManagedObjectContext:context];
    
    if (state == kStateLess) {
        taggedQuestions = [taggedQuestions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"learnStats.@count = 0"]];
    }
    else {
        Settings *settings = [Settings sharedSettings];
        taggedQuestions = [taggedQuestions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY learnStats.licenseClass = %d AND ALL learnStats.state = %d",
                                                                        settings.licenseClass,  state]];
    }
    
    return taggedQuestions;
}

- (StatisticState)answerState:(NSArray *)answers
{   
    if ([self.type isEqual:@"number"]) {
        NSNumber *correctNumber = nil;
        if ([answers count] == 2) {
            for (NSObject *obj in answers) {
                if (![obj isKindOfClass:[NSNumber class]]) return kFaultyAnswered;
            }
            
            correctNumber = [NSNumber numberWithDouble:[[NSString stringWithFormat:@"%d.%d", [[answers objectAtIndex:0] intValue], [[answers objectAtIndex:1] intValue]] doubleValue]];
        }
        else if ([answers count] == 1 && [[answers objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
            correctNumber = [answers objectAtIndex:0];
        }
        
        if (correctNumber) {
            Answer *answer = (Answer *)[[self.choices allObjects] objectAtIndex:0];
            
            BOOL correct;
            if ([[correctNumber stringValue] rangeOfString:@"."].location == NSNotFound) {
                correct = [correctNumber intValue] == [answer.correctNumber intValue];
            }
            else {
                correct = [correctNumber floatValue] == [answer.correctNumber floatValue];
            }
            
            return correct ? kCorrectAnswered : kFaultyAnswered;
        }
        return kFaultyAnswered;
    }
    
	int numCorrectAnswered = 0;
	int numCorrectAnswers = 0;
	
	for (int i = 0; i < [answers count]; i++) {
		
		if ([[answers objectAtIndex:i] isKindOfClass:[Answer class]]) {
			Answer *answer = (Answer *)[answers objectAtIndex:i];
			
			if ([answer.correct boolValue] == NO) {
				return kFaultyAnswered;
			}
			
			numCorrectAnswered++;
		}
	}
	
	for (int i = 0; i < [self.choices count]; i++) {
		
		Answer *choice = (Answer *)[[self.choices allObjects] objectAtIndex:i];
		if ([choice.correct boolValue] == YES) {
			numCorrectAnswers++;
		}
		
	}
	
	return numCorrectAnswered == numCorrectAnswers ? kCorrectAnswered : kFaultyAnswered;
}

- (void)setTagged:(BOOL)tagged inManagedObjectContext:(NSManagedObjectContext *)context
{
    [QuestionTags setTagged:tagged forQuestion:self inManagedObjectContext:context];
}

- (BOOL)isQuestionTagged
{
    return [QuestionTags isQuestionTagged:self];
}

- (NSSet *)rearrangedChoices
{
    if (_rearrangedChoices == nil) {
        NSMutableArray *questionChoices = [NSMutableArray arrayWithArray:[self.choices allObjects]];
        
        NSUInteger count = [questionChoices count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            NSUInteger nElements = count - i;
            NSUInteger n = (arc4random() % nElements) + i;
            [questionChoices exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        _rearrangedChoices = [NSSet setWithArray:questionChoices];
    }
    
    return _rearrangedChoices;
}

- (QuestionType)whatType
{
    return [self.type isEqual:@"number"] ? kNumberQuestion : kChoiceQuestion;
}


@dynamic image;
@dynamic whatTags;
@dynamic points;
@dynamic prefix;
@dynamic licenseClassFlag;
@dynamic number;
@dynamic order;
@dynamic text;
@dynamic type;
@dynamic learnStats;
@dynamic containedIn;
@dynamic choices;
@dynamic whatExamQuestions;
@dynamic deleted;

@end
