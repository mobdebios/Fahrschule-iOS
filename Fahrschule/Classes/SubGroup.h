//
//  SubGroup.h
//  Fahrschule
//
//  Created by Johan Olsson on 17.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MainGroup;
@class Question;

@interface SubGroup :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) MainGroup * containedIn;
@property (nonatomic, retain) NSSet* contains;

+ (NSArray *)subGroupsInRelationsTo:(id)object inManagedObjectContext:(NSManagedObjectContext *)context;

@end


@interface SubGroup (CoreDataGeneratedAccessors)
- (void)addContainsObject:(Question *)value;
- (void)removeContainsObject:(Question *)value;
- (void)addContains:(NSSet *)value;
- (void)removeContains:(NSSet *)value;

@end

