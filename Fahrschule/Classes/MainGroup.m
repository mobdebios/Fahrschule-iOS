// 
//  MainGroup.m
//  Fahrschule
//
//  Created by Johan Olsson on 17.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "MainGroup.h"
#import "SubGroup.h"


@implementation MainGroup

+ (NSArray *)mainGroupsInManagedObjectContext:(NSManagedObjectContext *)context {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"MainGroup" inManagedObjectContext:context]];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"baseMaterial" ascending:NO]]];
	
	NSError *error = nil;
	return [context executeFetchRequest:request error:&error];
}

- (UIImage *)mainGroupImage{
    if (!self.image) return nil;
    return [UIImage imageNamed:[self.image stringByReplacingOccurrencesOfString:@".png" withString:@""]];
}

@dynamic name;
@dynamic image;
@dynamic baseMaterial;
@dynamic contains;

@end
