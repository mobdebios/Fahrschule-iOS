//
//  Checksum.m
//  Fahrschule
//
//  Created by Johan Olsson on 13.12.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

#import "Checksum.h"

@implementation Checksum

+ (NSString *)plistSHA1
{
#ifndef FAHRSCHULE_LITE
    // define path of Info.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!handle) {
        return @"";
    }
    
    CC_SHA1_CTX sha1;
    
    CC_SHA1_Init(&sha1);
    
    BOOL finished = NO;
    
    while (!finished) {
        NSData* fileData = [handle readDataToEndOfFile];
        CC_SHA1_Update(&sha1, [fileData bytes], [fileData length]);
        if([fileData length] == 0)
            finished = YES;
    }
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &sha1);
    NSString* checksum = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          digest[0], digest[1], 
                          digest[2], digest[3],
                          digest[4], digest[5],
                          digest[6], digest[7],
                          digest[8], digest[9],
                          digest[10], digest[11],
                          digest[12], digest[13],
                          digest[14], digest[15],
                          digest[16], digest[17],
                          digest[18], digest[19]];
    
    return checksum;
#else
    return @"00";
#endif
    
}

@end
