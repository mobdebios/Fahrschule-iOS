// 
//  SubGroup.m
//  Fahrschule
//
//  Created by Johan Olsson on 17.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "SubGroup.h"

#import "MainGroup.h"
#import "Question.h"

@implementation SubGroup

+ (NSArray *)subGroupsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context
{	
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (SubGroup *subGroup in ((MainGroup *)object).contains) {
#ifndef FAHRSCHULE_LITE
        if ([Question countQuestionsInRelationsTo:subGroup inManagedObjectContext:context] == 0)
            continue;
#endif
        [mutableArray addObject:subGroup];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    return [mutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@dynamic name;
@dynamic number;
@dynamic order;
@dynamic containedIn;
@dynamic contains;

@end