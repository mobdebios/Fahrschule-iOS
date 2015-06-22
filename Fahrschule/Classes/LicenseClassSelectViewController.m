//
//  LicenseClassSelectViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 20.04.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "LicenseClassSelectViewController.h"
//#import "GroupedCellBackgroundView.h"
//#import "LicenseClassTableViewCell.h"
//#import "UIColor+ColorWithHexString.h"


@implementation LicenseClassSelectViewController

@synthesize licenseClassesDict=_licenseClassesDict;
@synthesize keyList=_keyList;
@synthesize tableView=_tableView;

NSInteger intSort(id num1, id num2, void *context)
{
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

//- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
//{
//    self = [super initInManagedObjectContext:context];
//    if (self) {
//
//        _licenseClassesDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LicenseClasses" ofType:@"plist"]];
//        
//        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
//        [self.tableView setBackgroundColor:[UIColor clearColor]];
//        [self.tableView setBackgroundView:nil];
//        [self.tableView setDataSource:self];
//        [self.tableView setDelegate:self];
//        
//        self.keyList = [NSArray arrayWithObjects:@"1", @"2", @"8192", @"16384", @"4", @"8", @"16", @"32", @"64", @"128", @"512", @"1024", @"4096", nil];
//        
//        [self setTitle:NSLocalizedString(@"Führerscheinklasse", @"")];
//        
//        if (self.userSettings.licenseClass != kUnknownLicenseClass && self.userSettings.licenseClass != kLicenseClassS &&
//            self.userSettings.licenseClass != kLicenseClassM && !self.iPad) {
//            UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Zurück", @"") style:UIBarButtonItemStylePlain target:self action:@selector(closeModalView:)];
//            [self.navigationItem setLeftBarButtonItem:closeButton animated:NO];
//        }
//    }
//    return self;
//}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.tableView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
//    if (self.iPad) {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter"]];
//    }
//    else {
//        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_mitGitter"]];
//        iv.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
//        iv.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
//        [self.view addSubview:iv];
//
//    }
    
    [self.view addSubview:self.tableView];


}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.keyList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
//    LicenseClassTableViewCell *cell = (LicenseClassTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[LicenseClassTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
//    }
//    
//    GroupedCellBackgroundView *bgView = [[GroupedCellBackgroundView alloc] initWithFrame:CGRectZero];
//    bgView.fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_fragenkatalog.png"]];
//    bgView.borderColor = [UIColor lightGrayColor];
//    
//    GroupedCellBackgroundView *selBgView = [[GroupedCellBackgroundView alloc] initWithFrame:CGRectZero];
//    selBgView.fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_fragenkatalog_aktiv.png"]];
//    selBgView.borderColor = [UIColor lightGrayColor];
//    
//    if (indexPath.row == 0) {
//        bgView.position = CustomCellBackgroundViewPositionTop;
//        selBgView.position = CustomCellBackgroundViewPositionTop;
//    }
//    else if (indexPath.row == [self.keyList count] - 1) {
//        bgView.position = CustomCellBackgroundViewPositionBottom;
//        selBgView.position = CustomCellBackgroundViewPositionBottom;
//    }
//    else {
//        bgView.position = CustomCellBackgroundViewPositionMiddle;
//        selBgView.position = CustomCellBackgroundViewPositionMiddle;
//    }
//    
//    cell.backgroundView = bgView;
//    cell.selectedBackgroundView = selBgView;
//    
//    NSDictionary *currentLicenseClass = [self.licenseClassesDict objectForKey:[self.keyList objectAtIndex:indexPath.row]];
//    cell.imageView.image = [UIImage imageNamed:[currentLicenseClass objectForKey:@"image"]];
//    cell.textLabel.text = [currentLicenseClass objectForKey:@"title"];
//    cell.detailTextLabel.text = [currentLicenseClass objectForKey:@"desc"];
//    cell.classLabel.text = [currentLicenseClass objectForKey:@"class"];
//    
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
//        
//    if ([[self.keyList objectAtIndex:indexPath.row] isEqual:[NSString stringWithFormat:@"%d", self.userSettings.licenseClass]]) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    
//#ifdef FAHRSCHULE_LITE
//    if (indexPath.section == 0 && indexPath.row == 4) {
//        cell.textLabel.textColor = [UIColor blackColor];
//        cell.classLabel.textColor = [UIColor colorWithRGBHex:0x394E75];
//        cell.userInteractionEnabled = YES;
//    }
//    else {
//        cell.textLabel.textColor = [UIColor grayColor];
//        cell.classLabel.textColor = [UIColor grayColor];
//        cell.userInteractionEnabled = NO;
//    }
//#endif
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0) {
//        [self.userSettings setLicenseClass:[[self.keyList objectAtIndex:indexPath.row] intValue]];
//        
//        if (self.userSettings.licenseClass == kLicenseClassC1 || self.userSettings.licenseClass == kLicenseClassC || self.userSettings.licenseClass == kLicenseClassCE
//            || self.userSettings.licenseClass == kLicenseClassD1 || self.userSettings.licenseClass == kLicenseClassD) {
//            
//            [self.userSettings setTeachingType:kAdditionalLicense]; 
//        }
//        else if (self.userSettings.licenseClass == kLicenseClassMOFA) {
//            [self.userSettings setTeachingType:kFirstTimeLicense];
//        }
//        
//        [self.tableView reloadData];
//    }
//
//    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Actions

- (void)closeModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
