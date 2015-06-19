// 
//  LearningStatistic.m
//  Fahrschule
//
//  Created by Johan Olsson on 17.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "LearningStatistic.h"

#import "Answer.h"
#import "Question.h"
#import "Settings.h"
#import "MainGroup.h"
#import "SubGroup.h"

@implementation LearningStatistic

+ (NSArray *)statisticsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context showState:(StatisticState)state
{	
	Settings *settings = [Settings sharedSettings];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"LearningStatistic" inManagedObjectContext:context]];
	[request setSortDescriptors:nil];
	
	if (state != kStateLess) {
		if ([object isKindOfClass:[MainGroup class]]) {
			[request setPredicate:[NSPredicate
				predicateWithFormat:@"state = %d AND licenseClass = %d AND whatQuestion.containedIn.containedIn = %@", state, settings.licenseClass, (MainGroup *)object]];
		}
		else if ([object isKindOfClass:[SubGroup class]]) {
			[request setPredicate:[NSPredicate
				predicateWithFormat:@"state = %d AND licenseClass = %d AND whatQuestion.containedIn = %@", state, settings.licenseClass, (SubGroup *)object]];
		}
		else if ([object isKindOfClass:[Question class]]) {
			[request setPredicate:[NSPredicate
				predicateWithFormat:@"state = %d AND whatQuestion.containedIn = %@", state, (Question *)object]];
		}
		else {
			[request setPredicate:[NSPredicate predicateWithFormat:@"state = %d AND licenseClass = %d", state, settings.licenseClass]];
		}
	}
	else {
		if ([object isKindOfClass:[MainGroup class]]) {
			[request setPredicate:[NSPredicate
				predicateWithFormat:@"licenseClass = %d AND whatQuestion.containedIn.containedIn = %@", settings.licenseClass, (MainGroup *)object]];
		}
		else if ([object isKindOfClass:[SubGroup class]]) {
			[request setPredicate:[NSPredicate
				predicateWithFormat:@"licenseClass = %d AND whatQuestion.containedIn = %@", settings.licenseClass, (SubGroup *)object]];
		}
		else if ([object isKindOfClass:[Question class]]) {
			[request setPredicate:[NSPredicate predicateWithFormat:@"whatQuestion = %@", (Question *)object]];
		}
		else {
			[request setPredicate:[NSPredicate predicateWithFormat:@"licenseClass = %d", settings.licenseClass]];
		}
	}
	
	NSError *error = nil;
	return [context executeFetchRequest:request error:&error];
}

+ (NSUInteger)countStatisticsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context showState:(StatisticState)state
{
    Settings *settings = [Settings sharedSettings];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"LearningStatistic" inManagedObjectContext:context]];
    
	if (state != kStateLess) {
		if ([object isKindOfClass:[MainGroup class]]) {
			[request setPredicate:[NSPredicate
                                   predicateWithFormat:@"state = %d AND licenseClass = %d AND whatQuestion.containedIn.containedIn = %@",
                                   state, settings.licenseClass, (MainGroup *)object]];
		}
		else if ([object isKindOfClass:[SubGroup class]]) {
			[request setPredicate:[NSPredicate
                                   predicateWithFormat:@"state = %d AND licenseClass = %d AND whatQuestion.containedIn = %@", state, settings.licenseClass, (SubGroup *)object]];
		}
		else if ([object isKindOfClass:[Question class]]) {
			[request setPredicate:[NSPredicate
                                   predicateWithFormat:@"state = %d AND whatQuestion.containedIn = %@", state, (Question *)object]];
		}
		else {
			[request setPredicate:[NSPredicate predicateWithFormat:@"state = %d AND licenseClass = %d", state, settings.licenseClass]];
		}
	}
	else {
		if ([object isKindOfClass:[MainGroup class]]) {
			[request setPredicate:[NSPredicate
                                   predicateWithFormat:@"licenseClass = %d AND whatQuestion.containedIn.containedIn = %@", settings.licenseClass, (MainGroup *)object]];
		}
		else if ([object isKindOfClass:[SubGroup class]]) {
			[request setPredicate:[NSPredicate
                                   predicateWithFormat:@"licenseClass = %d AND whatQuestion.containedIn = %@", settings.licenseClass, (SubGroup *)object]];
		}
		else if ([object isKindOfClass:[Question class]]) {
			[request setPredicate:[NSPredicate predicateWithFormat:@"whatQuestion = %@", (Question *)object]];
		}
		else {
			[request setPredicate:[NSPredicate predicateWithFormat:@"licenseClass = %d", settings.licenseClass]];
		}
	}
	
	NSError *error = nil;
	return [context countForFetchRequest:request error:&error];
}

+ (StatisticState)addStatistics:(NSArray *)givenAnswers forQuestion:(Question *)question inManagedObjectContext:(NSManagedObjectContext *)context
{
	Settings *settings = [Settings sharedSettings];
	
	if (!settings.guestMode) {
        
        NSSet *classSet = [question.learnStats filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"licenseClass = %d", settings.licenseClass]];
		
		if ([classSet count] > 0) {
            StatisticState state = [question answerState:givenAnswers];
            if (state != kNotAnswered && state != kStateLess) {
                LearningStatistic *learnStat = (LearningStatistic *)[[classSet allObjects] lastObject];
                
                learnStat.state = [NSNumber numberWithInt:state];
                learnStat.date = [NSDate date];
            }
            
            return state;
		}
        else {
            StatisticState state = [question answerState:givenAnswers];
            
            LearningStatistic *stat = [NSEntityDescription insertNewObjectForEntityForName:@"LearningStatistic" inManagedObjectContext:context];
			stat.whatQuestion = question;
            stat.state = [NSNumber numberWithInt:state];
			stat.date = [NSDate date];
            stat.licenseClass = [NSNumber numberWithInt:settings.licenseClass];
            
            return state;
        }
	}
    
    return kStateLess;
}

+ (LearningStatistic *)latestStatistic:(NSManagedObjectContext *)context
{	
	Settings *settings = [Settings sharedSettings];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"LearningStatistic" inManagedObjectContext:context]];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"licenseClass = %d", settings.licenseClass]];
	
	NSError *error = nil;
	LearningStatistic *stat = [[context executeFetchRequest:request error:&error] lastObject];
	
	return stat;
}

+ (void)statisticsResetInManagedObjectContext:(NSManagedObjectContext *)context
{
    Settings *settings = [Settings sharedSettings];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"LearningStatistic" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"licenseClass = %d", settings.licenseClass]];
    [request setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *stats = [context executeFetchRequest:request error:&error];
    
    if (!error) {
        for (LearningStatistic *stat in stats) {
            [context deleteObject:stat];
        }
        
        [context save:nil];
    }
}

@dynamic date;
@dynamic licenseClass;
@dynamic whatQuestion;
@dynamic state;

@end
