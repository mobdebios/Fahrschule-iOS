//
//  NSArray+shuffleArray.m
//  Fahrschule
//
//  Created by Johan Olsson on 28.04.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "NSArray+shuffleArray.h"


@implementation NSArray (shuffleArray)

- (NSArray *)shuffleArray
{
    NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:self];
    
    NSUInteger count = [shuffledArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return [NSArray arrayWithArray:shuffledArray];
}

@end
