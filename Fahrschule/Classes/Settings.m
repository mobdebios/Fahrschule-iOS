//
//  Settings.m
//  Fahrschule
//
//  Created by Johan Olsson on 21.02.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "Settings.h"

NSString * const SettingsLicenseClassKey = @"licenseClass";
NSString * const SettingsTeachingTypeKey = @"teachingType";
NSString * const SettingsGuestModeKey = @"guestMode";
NSString * const SettingsNotificationDidChangeAnswersGiven = @"didChangeAnswersGiven";
NSString * const SettingsNotificationDidSelectQuestion = @"didSelectetQuestion";
NSString * const SettingsNotificationUpdateBadgeValue = @"updateBadgeValue";


@implementation Settings

@synthesize userDefaults=_userDefaults;

- (void)setLicenseClass:(LicenseClass)licenseClass
{
	[self.userDefaults setValue:[NSNumber numberWithInt:licenseClass] forKey:SettingsLicenseClassKey];
    [self.userDefaults synchronize];
    
    if ([self getCurrentLicenseClassTeachingTypeState] != kUnknownTeachingType) {
        self.teachingType = [self getCurrentLicenseClassTeachingTypeState];
    }
    else if (self.licenseClass == kLicenseClassC1 || self.licenseClass == kLicenseClassC || self.licenseClass == kLicenseClassCE
             || self.licenseClass == kLicenseClassD1 || self.licenseClass == kLicenseClassD) {
        self.teachingType = kAdditionalLicense;
    }
    else {
        self.teachingType = kFirstTimeLicense;
    }
}

- (LicenseClass)licenseClass
{
    NSNumber *ret = [self.userDefaults valueForKey:SettingsLicenseClassKey];
	return ret ? [ret intValue] : kUnknownLicenseClass;
}

- (void)setTeachingType:(TeachingType)teachingType
{
    [self.userDefaults setValue:[NSNumber numberWithInt:teachingType] forKey:SettingsTeachingTypeKey];
    [self setCurrentLicenseClassTeachingTypeState];
}

- (TeachingType)teachingType
{
    NSNumber *ret = [self.userDefaults valueForKey:SettingsTeachingTypeKey];
	return ret ? [ret intValue] : kUnknownTeachingType;
}


- (void)setGuestMode:(BOOL)guestMode {
    [self.userDefaults setBool:guestMode forKey:SettingsGuestModeKey];
}

- (BOOL)guestMode {
    return [self.userDefaults boolForKey:SettingsGuestModeKey];
}

- (void)setSolutionMode:(BOOL)solutionMode
{
    [self.userDefaults setValue:[NSNumber numberWithBool:solutionMode] forKey:@"solutionMode"];
}

- (BOOL)solutionMode
{
    /*NSNumber *ret = [self.userDefaults valueForKey:@"solutionMode"];
	return ret ? [ret boolValue] : NO;*/
    return NO;
}

- (void)setOfficialQuestionViewMode:(BOOL)officialQuestionViewMode
{
    [self.userDefaults setValue:[NSNumber numberWithBool:officialQuestionViewMode] forKey:@"officialQuestionViewMode"];
}

- (BOOL)officialQuestionViewMode
{
    NSNumber *ret = [self.userDefaults valueForKey:@"officialQuestionViewMode"];
	return ret ? [ret boolValue] : NO;
}

- (void)setVelocity:(NSUInteger)velocity
{
    [self.userDefaults setValue:[NSNumber numberWithInteger:velocity] forKey:@"velocity"];
}

- (NSUInteger)velocity
{
    NSNumber *ret = [self.userDefaults valueForKey:@"velocity"];
	return ret ? [ret integerValue] : 0;
}

- (void)setScrollY:(NSUInteger)scrollY
{
    [self.userDefaults setValue:[NSNumber numberWithInteger:scrollY] forKey:@"scrollY"];
}

- (NSUInteger)scrollY
{
    NSNumber *ret = [self.userDefaults valueForKey:@"scrollY"];
	return ret ? [ret integerValue] : 0;
}

- (void)setFormulaIndex:(NSUInteger)formulaIndex
{
    [self.userDefaults setValue:[NSNumber numberWithInteger:formulaIndex] forKey:@"formulaIndex"];
}

- (NSUInteger)formulaIndex
{
    NSNumber *ret = [self.userDefaults valueForKey:@"formulaIndex"];
	return ret ? [ret integerValue] : 0;
}

- (NSUInteger)deviceDatabaseVersion
{
    NSNumber *ret = [self.userDefaults valueForKey:@"deviceDatabaseVersion"];
	return ret ? [ret integerValue] : 0;
}

- (void)setDeviceDatabaseVersion:(NSUInteger)currentDatabaseVersion
{
    [self.userDefaults setValue:[NSNumber numberWithInteger:currentDatabaseVersion] forKey:@"deviceDatabaseVersion"];
}

- (void)setCurrentLicenseClassTeachingTypeState
{
    [self.userDefaults setValue:[NSNumber numberWithInt:self.teachingType] forKey:[NSString stringWithFormat:@"LicenseClassState%zd", self.licenseClass]];
}

- (TeachingType)getCurrentLicenseClassTeachingTypeState
{
    NSNumber *ret = [self.userDefaults valueForKey:[NSString stringWithFormat:@"LicenseClassState%zd", self.licenseClass]];
    return ret ? (TeachingType) [ret integerValue] : kUnknownTeachingType;
}

- (BOOL)hasSeenLicenseClassChangeMessage
{
    NSNumber *ret = [self.userDefaults valueForKey:@"hasSeenLicenseClassChangeMessage"];
    
    if (ret)
        return YES;
    
    [self.userDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"hasSeenLicenseClassChangeMessage"];
	return NO;
}

- (NSUInteger)latestDatabaseVersion
{
    /*
     * Database version list
     *
     * 1.0.0 - 20110714
     * 1.0.1 - 20110815
     * 1.3.0 - 20120806
     * 1.4.0 - 20130108
     * 1.5.0 - 20130401
     * 1.6.0 - 20131016
     */
    return 20131016;
}

- (NSString *)iTunesLink
{
    return @"http://itunes.apple.com/de/app/pocket-fahrschule/id436764243?mt=8";
}

- (NSString *)iTunesLiteLink
{
    return @"http://itunes.apple.com/de/app/pocket-fahrschule/id457525697?mt=8";
}

#pragma mark - iPad setting values

- (SettingsView)lastActiveSettingsView
{
    NSNumber *ret = [self.userDefaults valueForKey:@"lastActiveSettingsView"];
	return ret ? [ret intValue] : kLicenseClassSelectorView;
}

- (void)setLastActiveSettingsView:(SettingsView)lastActiveSettingsView
{
    [self.userDefaults setValue:[NSNumber numberWithInt:lastActiveSettingsView] forKey:@"lastActiveSettingsView"];
}

- (ExtrasView)lastActiveExtrasView
{
    NSNumber *ret = [self.userDefaults valueForKey:@"lastActiveExtrasView"];
	return ret ? [ret intValue] : kFormulasView;
}

- (void)setLastActiveExtrasView:(ExtrasView)lastActiveExtrasView
{
    [self.userDefaults setValue:[NSNumber numberWithInt:lastActiveExtrasView] forKey:@"lastActiveExtrasView"];
}

#pragma mark -

- (NSDictionary *)examSheetDictionary
{
    if (!_examSheetDictionary) {
        _examSheetDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ExamSheet" ofType:@"plist"]];
    }
    
    return _examSheetDictionary;
}

- (NSInteger)numberOfAdditionalQuestionsExam
{
    return [[[[[self.examSheetDictionary objectForKey:[NSString stringWithFormat:@"%zd", self.licenseClass]]
                           objectForKey:[NSString stringWithFormat:@"%zd", self.teachingType]] objectForKey:@"Zusatzstoff"] objectForKey:@"totalquestions"] integerValue];
}

- (NSString *)licenseClassString
{
    switch (self.licenseClass) {
        case kLicenseClassA:
            return @"A";
            break;
        case kLicenseClassA1:
            return @"A1";
            break;
        case kLicenseClassB:
            return @"B";
            break;
        case kLicenseClassC:
            return @"C";
            break;
        case kLicenseClassC1:
            return @"C1";
            break;
        case kLicenseClassCE:
            return @"CE";
            break;
        case kLicenseClassD:
            return @"D";
            break;
        case kLicenseClassD1:
            return @"D1";
            break;
        case kLicenseClassL:
            return @"L";
            break;
        case kLicenseClassM:
            return @"M";
            break;
        case kLicenseClassMOFA:
            return @"MOFA";
            break;
        case kLicenseClassS:
            return @"S";
            break;
        case kLicenseClassT:
            return @"T";
            break;
        case kLicenseClassA2:
            return @"A2";
            break;
        case kLicenseClassAM:
            return @"AM";
            break;
        default:
            return @"Unknown";
            break;
    }
}

static Settings *sharedInstance = nil;

+ (id)sharedSettings {
    static Settings *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[Settings alloc] init];
    });
    return __instance;
}

+ (id)allocWithZone:(NSZone*)zone
{
    //Usually already set by +initialize.
    if (sharedInstance) {
        //The caller expects to receive a new object, so implicitly retain it
        //to balance out the eventual release message.
        return sharedInstance;
    } else {
        //When not already set, +initialize is our caller.
        //It's creating the shared instance, let this go through.
        return [super allocWithZone:zone];
    }
}

- (id)init
{
    //If sharedInstance is nil, +initialize is our caller, so initialize the instance.
    //If it is not nil, simply return the instance without re-initializing it.
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        _examSheetDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ExamSheet" ofType:@"plist"]];
    }
    return self;
}


@end
