//
//  Checksum.h
//  Fahrschule
//
//  Created by Johan Olsson on 13.12.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#if TARGET_IPHONE_SIMULATOR
#define INFO_PLIST_SHA1 @"0f7021c5fedada10720173939d4e2a841abd7ef8"
#else
#define INFO_PLIST_SHA1 @"946bf6ebf5c413ed12d0104ebf00725c73a6e061"
#endif
@interface Checksum : NSObject

+ (NSString *)plistSHA1;

@end
