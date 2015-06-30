//
//  Settings.h
//  Fahrschule
//
//  Created by Johan Olsson on 21.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const SettingsLicenseClassKey;
FOUNDATION_EXTERN NSString * const SettingsTeachingTypeKey;

FOUNDATION_EXTERN NSString * const SettingsNotificationDidChangeAnswersGiven;
FOUNDATION_EXTERN NSString * const SettingsNotificationDidSelectQuestion;
FOUNDATION_EXTERN NSString * const SettingsNotificationUpdateBadgeValue;






typedef NS_ENUM(NSInteger, TeachingType) {
    kFirstTimeLicense = 1,
    kAdditionalLicense = 2,
    kUnknownTeachingType = 4
    
};


typedef NS_ENUM(NSInteger, LicenseClass) {
    kLicenseClassA = 1,
    kLicenseClassA1 = 2,
    kLicenseClassB = 4,
    kLicenseClassC = 8,
    kLicenseClassC1 = 16,
    kLicenseClassCE = 32,
    kLicenseClassD = 64,
    kLicenseClassD1 = 128,
    kLicenseClassS = 256,
    kLicenseClassT = 512,
    kLicenseClassL = 1024,
    kLicenseClassM = 2048,
    kLicenseClassMOFA = 4096,
    kLicenseClassA2 = 8192,
    kLicenseClassAM = 16384,
    kUnknownLicenseClass = -1
};

/*
 * iPad
 */
typedef enum {
    kLicenseClassSelectorView = 1,
    kTeachingTypeSelectorView = 2,
    kImpressumView = 3
} SettingsView;

typedef enum {
    kFormulasView = 1,
    kBrakingDistanceView = 2,
    kTrafficSignsView = 3,
    kStVOView = 4
} ExtrasView;

@interface Settings : NSObject {
    NSDictionary *_examSheetDictionary;
}

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, assign) LicenseClass licenseClass;
@property (nonatomic, readonly) NSString *licenseClassString;
@property (nonatomic, assign) TeachingType teachingType;
@property (nonatomic, assign) BOOL guestMode;
@property (nonatomic, assign) BOOL solutionMode;
@property (nonatomic, assign) BOOL officialQuestionViewMode;
@property (nonatomic, assign) NSUInteger velocity;
@property (nonatomic, assign) NSUInteger scrollY;
@property (nonatomic, assign) NSUInteger formulaIndex;
@property (nonatomic, assign) NSUInteger deviceDatabaseVersion;
@property (nonatomic, readonly) NSUInteger latestDatabaseVersion;
@property (nonatomic, readonly) NSDictionary *examSheetDictionary;
@property (nonatomic, readonly) NSString *iTunesLink;
@property (nonatomic, readonly) NSString *iTunesLiteLink;

/*
 * iPad
 */
@property (nonatomic, assign) SettingsView lastActiveSettingsView;
@property (nonatomic, assign) ExtrasView lastActiveExtrasView;

+ (id)sharedSettings;
- (void)setCurrentLicenseClassTeachingTypeState;
- (TeachingType)getCurrentLicenseClassTeachingTypeState;
- (BOOL)hasSeenLicenseClassChangeMessage;
- (NSInteger)numberOfAdditionalQuestionsExam;

@end
