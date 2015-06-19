//
//  MainGroup.h
//  Fahrschule
//
//  Created by Johan Olsson on 17.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SubGroup;

@interface MainGroup :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * baseMaterial;
@property (nonatomic, retain) NSSet* contains;

+ (NSArray *)mainGroupsInManagedObjectContext:(NSManagedObjectContext *)context;
- (UIImage *)mainGroupImage;

@end


@interface MainGroup (CoreDataGeneratedAccessors)
- (void)addContainsObject:(SubGroup *)value;
- (void)removeContainsObject:(SubGroup *)value;
- (void)addContains:(NSSet *)value;
- (void)removeContains:(NSSet *)value;

@end

