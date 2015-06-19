// 
//  ExamStatistic.m
//  Fahrschule
//
//  Created by Johan Olsson on 18.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "ExamStatistic.h"
#import "ExamQuestion.h"
#import "Answer.h"
#import "Settings.h"
#import "QuestionModel.h"

@interface ExamStatistic (hidden)

- (void)calculateAndSetNumberOfFaultyPoints;
+ (NSURL *)applicationDocumentsDirectory;

@end

@implementation ExamStatistic (hidden)

- (void)calculateAndSetNumberOfFaultyPoints
{
    NSUInteger points = 0;
    
    for (ExamQuestion *examQ in self.whatQuestions) {
        points += [examQ faultyPoints];
    }
    
    self.faultyPoints = [NSNumber numberWithInt:points];
}

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end


@implementation ExamStatistic

+ (void)recalculateFaultyPointsForAllExamsInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"ExamStatistic" inManagedObjectContext:context]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"state = %d", kFinishedExam]];
	
	NSError *error;
	NSArray *exams = [context executeFetchRequest:request error:&error];
    for (ExamStatistic *exam in exams) {
        [exam calculateAndSetNumberOfFaultyPoints];
    }
}

+ (NSArray *)statisticsInManagedObjectContext:(NSManagedObjectContext *)context fetchLimit:(int)limit
{	
	return [ExamStatistic statisticsInManagedObjectContext:context fetchLimit:limit state:kFinishedExam];
}

+ (NSArray *)statisticsInManagedObjectContext:(NSManagedObjectContext *)context fetchLimit:(int)limit state:(ExamState)state
{
    Settings *settings = [Settings sharedSettings];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"ExamStatistic" inManagedObjectContext:context]];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"teachingType = %d AND licenseClass = %d AND state = %d", settings.teachingType, settings.licenseClass, state]];
	if (limit > 0) {
		[request setFetchLimit:limit];
	}
	
	NSError *error;
	return [context executeFetchRequest:request error:&error];
}

+ (ExamStatistic *)insertNewStatistics:(NSManagedObjectContext *)context state:(ExamState)state
{
	ExamStatistic *stat = nil;
	Settings *settings = [Settings sharedSettings];
	
	if (!settings.guestMode) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"ExamStatistic" inManagedObjectContext:context]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"teachingType = %d AND licenseClass = %d AND state = %d", settings.teachingType, settings.licenseClass, kCanceledExam]];
        
        NSError *error;
        stat = [[context executeFetchRequest:request error:&error] lastObject];
        if (stat) {
            stat.date = [NSDate date];
            stat.state = [NSNumber numberWithInt:state];
        }
        else {
            stat = [NSEntityDescription insertNewObjectForEntityForName:@"ExamStatistic" inManagedObjectContext:context];
            stat.licenseClass = [NSNumber numberWithInt:settings.licenseClass];
            stat.date = [NSDate date];
            stat.teachingType = [NSNumber numberWithInt:settings.teachingType];
            stat.state = [NSNumber numberWithInt:state];
            stat.whatQuestions = [[NSSet alloc] init];
        }
	}
	
	return stat;
}

+ (NSArray *)datesForMonthIndicators:(NSManagedObjectContext *)context
{
    Settings *settings = [Settings sharedSettings];
    
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    
    sqlite3 *database;
    NSString *dbPath = [[[ExamStatistic applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fahrschule.sqlite"] path];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        NSString *query = [[NSString stringWithFormat:@"SELECT MIN(ZDATE) FROM ZEXAMSTATISTIC WHERE ZTEACHINGTYPE = %d AND ZLICENSECLASS = %d AND ZSTATE = %d",
                            settings.teachingType, settings.licenseClass, kFinishedExam]
                           stringByAppendingString:@" GROUP BY strftime('%Y%m', strftime('%s', ZDATE, 'unixepoch') + 978307200, 'unixepoch');"];
        
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(database, [query cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                NSString *date = [NSString stringWithFormat:@"%f", [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)] doubleValue]];
                [dates addObject:date];
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    
    return dates;
}

- (NSArray *)questionModelsForExam
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortedQuestionArray = [[self.whatQuestions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:[sortedQuestionArray count]];
    
    for (ExamQuestion *eq in sortedQuestionArray) {
        QuestionModel *qm = [[QuestionModel alloc] initWithQuestion:eq.whatQuestion atIndex:[eq.order intValue]];
        qm.isTagged = [eq.tagged boolValue];
        
        NSMutableArray *answerdMArray = [[NSMutableArray alloc] init];
        if ([eq.whatQuestion whatType] == kNumberQuestion) {
            
            if ([eq.whatQuestion.number isEqualToString:@"11.11.1"]) {
                
                if ([[eq.givenNumberAnswer stringValue] isEqualToString:@"-1"]) {
                    [answerdMArray addObject:[NSNumber numberWithInt:-1]];
                    [answerdMArray addObject:[NSNumber numberWithInt:-1]];
                }
                else {
                    
                    NSArray *correctNumbers = [[eq.givenNumberAnswer stringValue] componentsSeparatedByString:@"."];
                    
                    [answerdMArray addObject:[NSNumber numberWithInt:[[correctNumbers objectAtIndex:0] intValue]]];
                    
                    if ([correctNumbers count] > 1) {
                        [answerdMArray addObject:[NSNumber numberWithInt:[[correctNumbers objectAtIndex:1] intValue]]];
                    }
                    else {
                        [answerdMArray addObject:[NSNumber numberWithInt:-1]];
                    }
                }
            }
            else {
                [answerdMArray addObject:eq.givenNumberAnswer];
            }
        }
        else {
            for (Answer *a in eq.givenAnswers) {
                [answerdMArray addObject:a];
            }
        }
        
        qm.givenAnswers = answerdMArray;

        
        [mArray insertObject:qm atIndex:[eq.order intValue]];

    }
    
    return [NSArray arrayWithArray:mArray];
}

- (NSArray *)questionsForExam
{
    NSMutableArray *mArray = [NSMutableArray new];
    
    for (ExamQuestion *eq in self.whatQuestions) {
        [mArray addObject:eq.whatQuestion];
    }
    
    return [NSArray arrayWithArray:mArray];
}

- (void)deleteExamInManagedObjectContext:(NSManagedObjectContext *)context
{
    for (ExamQuestion *eq in self.whatQuestions) {
        [context deleteObject:eq];
    }
    
    [context deleteObject:self];
    
    NSError *error = nil;
    [context save:&error];
}

- (void)addStatisticsWithModel:(QuestionModel *)model inManagedObjectContext:(NSManagedObjectContext *)context
{
	Settings *settings = [Settings sharedSettings];
	
	if (!settings.guestMode) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"ExamQuestion" inManagedObjectContext:context]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"whatQuestion = %@ AND whatExam = %@", model.question, self]];
        
        NSError *error;
        ExamQuestion *examQ = [[context executeFetchRequest:request error:&error] lastObject];
        
        if (!examQ) {
            examQ = [NSEntityDescription insertNewObjectForEntityForName:@"ExamQuestion" inManagedObjectContext:context];
            
            if (!examQ) {
                return;
            }
            
            examQ.whatExam = self;
            examQ.order = [NSNumber numberWithInt:model.index];
            examQ.whatQuestion = model.question;
        }
		
        if ([model.question whatType] == kNumberQuestion) {
            if ([examQ.whatQuestion.number isEqualToString:@"11.11.1"]) {
                NSString *value = @"";
                for (NSNumber *number in model.givenAnswers) {
                    value = [value stringByAppendingFormat:@"%d.", [number intValue]];
                }
                examQ.givenNumberAnswer = [NSNumber numberWithFloat:[[value substringToIndex:[value length] - 1] floatValue]];
            }
            else {
                examQ.givenNumberAnswer = [model.givenAnswers objectAtIndex:0];
            }
        }
        else {
            NSMutableSet *givenAnswersSet = [[NSMutableSet alloc] init];
            for (int i = 0; i < [model.givenAnswers count]; i++) {
                
                if ([[model.givenAnswers objectAtIndex:i] isKindOfClass:[Answer class]]) {
                    Answer *answer = (Answer *)[model.givenAnswers objectAtIndex:i];
                    [givenAnswersSet addObject:answer];
                }
            }
            
            if ([model.givenAnswers count] > 0) {
                examQ.givenAnswers = [NSSet setWithSet:givenAnswersSet];
            }

        }
        
        examQ.tagged = [NSNumber numberWithBool:model.isTagged];
        [self calculateAndSetNumberOfFaultyPoints];
	}
}

- (NSUInteger)numberOfFaultyAnsweredQuestions
{
    NSUInteger num = 0;
    
    for (ExamQuestion *examQ in self.whatQuestions) {
        if (![examQ hasAnsweredCorrectly]) num++;
    }
    
    return num;
}

- (BOOL)hasPassed
{
    Settings *settings = [Settings sharedSettings];
    NSInteger maxPoints = [[[[settings.examSheetDictionary objectForKey:[NSString stringWithFormat:@"%d", settings.licenseClass]]
                                       objectForKey:[NSString stringWithFormat:@"%d", settings.teachingType]] objectForKey:@"MaxPoints"] intValue];
    if (maxPoints == 10 && [self.faultyPoints intValue] == 10) {
        NSArray *arr = [[self.whatQuestions allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"whatQuestion.points = 5"]];
        int numFalse = 0;
        for (ExamQuestion *q in arr) {
            if (![q hasAnsweredCorrectly]) {
                numFalse++;
            }
        }
        return numFalse != 2;
    }
    
    return [self.faultyPoints intValue] <= maxPoints;
}

@dynamic date;
@dynamic faultyPoints;
@dynamic index;
@dynamic licenseClass;
@dynamic state;
@dynamic teachingType;
@dynamic timeLeft;
@dynamic whatQuestions;

@end
