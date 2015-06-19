//
//  GraphDiagramController.m
//  Fahrschule
//
//  Created by Johan Olsson on 19.05.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "GraphDiagramController.h"
#import "ExamStatistic.h"
//#import "MonthIndicatorLabel.h"


@implementation GraphDiagramController



int NUM_OF_RESULTS_SHOWN = 7;
static CGFloat Y_DELTA = 0.0;
static CGFloat INNER_HEIGHT = 0.0;
static CGFloat START_OFFSET = 30.0;

NSInteger intSort2(id num1, id num2, void *context)
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
//        if (self.iPad) {
//            NUM_OF_RESULTS_SHOWN = 14;
//        }
//        
//        self.hidesBottomBarWhenPushed = YES;
//        
//        self.examStatistics = [ExamStatistic statisticsInManagedObjectContext:context fetchLimit:-1];
//        
//        NSDictionary *examSheetDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ExamSheet" ofType:@"plist"]];
//        self.maxPoints = [[[[examSheetDictionary objectForKey:[NSString stringWithFormat:@"%d", self.userSettings.licenseClass]]
//                                           objectForKey:[NSString stringWithFormat:@"%d", self.userSettings.teachingType]] objectForKey:@"MaxPoints"] intValue];
//
//        
//        _visibleMonthIndicators = [[NSMutableDictionary alloc] init];
//        _visibleResults = [[NSMutableDictionary alloc] init];
//        
//        _dateFormatter = [[NSDateFormatter alloc] init];
//        [self.dateFormatter setDateFormat:@"dd MMM %@yy"];
//        
//        _monthFormatter = [[NSDateFormatter alloc] init];
//        [self.monthFormatter setDateFormat:@"MMM"];
//        
//        self.datesForMonthIndicators = [ExamStatistic datesForMonthIndicators:self.managedObjectContext];
//    }
//    return self;
//}

#pragma mark - View lifecycle
/*
- (void)viewDidLoad
{
    [super viewDidLoad];

    INNER_HEIGHT = self.chartScrollView.frame.size.height - 36.0;
    
    CGFloat contentWidth = ceilf(((float)[self.examStatistics count] / (float)NUM_OF_RESULTS_SHOWN) * self.chartScrollView.frame.size.width) + START_OFFSET;
    self.chartScrollView.contentSize = CGSizeMake(contentWidth, self.chartScrollView.frame.size.height);
    
    NSMutableArray *examStats = [[NSMutableArray alloc] init];
    NSInteger maxGraphValue = self.maxPoints * 2;
    NSInteger count = [self.examStatistics count] > NUM_OF_RESULTS_SHOWN ? NUM_OF_RESULTS_SHOWN : [self.examStatistics count] - 1;
    for (int i = 0; i <= count; i++) {  
        
        ExamStatistic *examStat = [self.examStatistics objectAtIndex:i];
        if (examStat) {
            maxGraphValue = [examStat.faultyPoints intValue] > maxGraphValue ? [examStat.faultyPoints intValue] : maxGraphValue;
            [examStats addObject:examStat];
        }
    }
    
    Y_DELTA = (INNER_HEIGHT - 32.0) / maxGraphValue;
    for (int i = 0; i < [examStats count]; i++) {
        ExamStatistic *examStat =  (ExamStatistic *)[examStats objectAtIndex:i];
        
        CGFloat x_delta = floorf(self.chartScrollView.frame.size.width / NUM_OF_RESULTS_SHOWN) * i + START_OFFSET;
        CGFloat current_y = INNER_HEIGHT - Y_DELTA * [examStat.faultyPoints floatValue] - 33.0;
        current_y = current_y < 0.0 ? 0.0 : current_y;
        
        NSString *month = [self.monthFormatter stringFromDate:examStat.date];
        NSString *dateStr = [NSString stringWithFormat:@"%f", [examStat.date timeIntervalSinceReferenceDate]];
        if (![self.visibleMonthIndicators objectForKey:month] && [self.datesForMonthIndicators containsObject:dateStr]) {
            MonthIndicatorLabel *monthIndicator = [[MonthIndicatorLabel alloc] initWithFrame:CGRectMake(x_delta - 4.0, INNER_HEIGHT - 5.0, 40.0, 38.0)];
            monthIndicator.text = month;
            [self.chartScrollView addSubview:monthIndicator];
            [self.visibleMonthIndicators setObject:monthIndicator forKey:month];

        }
        
        GraphView *graphView = [[GraphView alloc] initWithFrame:CGRectMake(x_delta, current_y, 36.0, 46.0) andExamStatistic:examStat andIndex:i];
        graphView.delegate = self;
        [self.chartScrollView addSubview:graphView];
        [self.visibleResults setObject:graphView forKey:[NSNumber numberWithInt:i]];

    }

    
    if (self.iPad) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Schließen", @"")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(closeModalView:)];
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.iPad) {
        [self.graphOfAFunctionView setNeedsDisplay];
        [self.chartScrollView setNeedsDisplay];
        [self.chartScrollView setNeedsLayout];
    }
    else {
        UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
        if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == 0 || currentOrientation == 5) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.iPad) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Graph view delegate

- (void)graphViewSelected:(GraphView *)graphView atIndex:(NSInteger)index
{
    ExamStatistic *exam = [self.examStatistics objectAtIndex:index];
    if (exam) {
        CGRect rect = self.dateBalloonView.frame;
        
        if (graphView.point.y - 74.0 < -4) {
            self.dateBalloonView.frame = CGRectMake(graphView.point.x - 45.0, graphView.point.y + 10.0, rect.size.width, rect.size.height);
            self.dateBalloonView.transform = CGAffineTransformMakeRotation(M_PI);
            self.dateBalloonView.textLabel.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else {
            self.dateBalloonView.frame = CGRectMake(graphView.point.x - 45.0, graphView.point.y - 74.0, rect.size.width, rect.size.height);
            self.dateBalloonView.transform = CGAffineTransformMakeRotation(0);
            self.dateBalloonView.textLabel.transform = CGAffineTransformMakeRotation(0);
        }
        
        self.dateBalloonView.textLabel.text = [NSString stringWithFormat:[self.dateFormatter stringFromDate:exam.date], @"'"];
        self.dateBalloonView.index = index;
        
        // Animate the fade-in
        self.dateBalloonView.alpha = 1.0;
        [UIView animateWithDuration:0.25 delay:10.0 options:UIViewAnimationOptionCurveLinear animations:^(void) {
            self.dateBalloonView.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - Graph scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat x_delta = floorf(scrollView.frame.size.width / NUM_OF_RESULTS_SHOWN);
    NSUInteger index = (NSUInteger)floorf((scrollView.bounds.origin.x - START_OFFSET - 18.0) / x_delta) + 1;
    
    [self addMissingAndRemoveOldGraphViews:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.graphOfAFunctionView.frame = scrollView.bounds;
    [self.graphOfAFunctionView setNeedsDisplay];
    static NSUInteger index = 0;
    
    CGFloat x_delta = floorf(scrollView.frame.size.width / (CGFloat)NUM_OF_RESULTS_SHOWN);
    NSUInteger newIndex = (NSUInteger)floorf((scrollView.bounds.origin.x - START_OFFSET - 18.0) / x_delta) + 1;
    
    if (index == newIndex) return;
    index = newIndex;
    
    NSInteger prevVisibleIndex = index - 1;
    NSInteger nextVisibleIndex = index + NUM_OF_RESULTS_SHOWN;
    
    if ([self.examStatistics count] - (NSInteger)index - NUM_OF_RESULTS_SHOWN > 0) {
        GraphView *gv = nil;
        if ((gv = [self.visibleResults objectForKey:[NSNumber numberWithInt:prevVisibleIndex - 1]])) {
            [gv removeFromSuperview];
            [self.visibleResults removeObjectForKey:[NSNumber numberWithInt:prevVisibleIndex - 1]];
        }
        
        if ((gv = [self.visibleResults objectForKey:[NSNumber numberWithInt:nextVisibleIndex + 1]])) {
            [gv removeFromSuperview];
            [self.visibleResults removeObjectForKey:[NSNumber numberWithInt:nextVisibleIndex + 1]];
        }
    }
    
    if (![self.visibleResults objectForKey:[NSNumber numberWithInt:prevVisibleIndex]]) {
        [self addNewGraphView:prevVisibleIndex];
    }
    
    if (![self.visibleResults objectForKey:[NSNumber numberWithInt:nextVisibleIndex]]) {
        [self addNewGraphView:nextVisibleIndex];
    }
}

#pragma mark - Graph of a function view delegate

- (NSArray *)graphOfAFunctionViewPointsArray:(GraphOfAFunctionView *)graphOfAFunctionView
{
    NSArray *keys = [[self.visibleResults allKeys] sortedArrayUsingFunction:intSort2 context:NULL];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    for (NSNumber *key in keys) {
        GraphView *gv = [self.visibleResults objectForKey:key];
        [points addObject:[NSValue valueWithCGPoint:gv.point]];
    }
    return [NSArray arrayWithArray:points];
}

# pragma mark - Actions

- (void)addNewGraphView:(NSUInteger)index
{
    if (index > [self.examStatistics count] - 1) return;
    
    ExamStatistic *examStat = [self.examStatistics objectAtIndex:index];
    
    CGFloat x_delta = floorf(self.chartScrollView.frame.size.width / NUM_OF_RESULTS_SHOWN);
    
    NSInteger maxFault = [examStat.faultyPoints intValue] > self.maxPoints * 2 ? [examStat.faultyPoints intValue] : self.maxPoints * 2;
    for (GraphView *gv in [self.visibleResults allValues]) {
        maxFault = gv.faults > maxFault ? gv.faults : maxFault;
    }
    
    CGFloat new_y_delta = (INNER_HEIGHT - 32.0) / [[NSNumber numberWithInt:maxFault] floatValue];
    if (Y_DELTA != new_y_delta) {
        Y_DELTA = new_y_delta;
        
        CATransition *anim = [CATransition animation];
        [anim setType:kCATransitionFade];
        [anim setSubtype:kCATransitionFromTop];
        [anim setDuration:0.15];
        [self.graphOfAFunctionView.layer addAnimation:anim forKey:@""];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        // Move points
        for (GraphView *gv in [self.visibleResults allValues]) {
            CGFloat current_y = INNER_HEIGHT - Y_DELTA * (float)gv.faults - 33.0;            
            gv.frame = CGRectMake(gv.frame.origin.x, current_y, 36.0, 46.0);
        }
        
        // Move balloon
        CGRect rect = CGRectMake(self.chartScrollView.contentOffset.x, self.chartScrollView.contentOffset.y,
                                 self.chartScrollView.frame.size.width,self.chartScrollView.frame.size.height);
        if (CGRectIntersectsRect(rect, self.dateBalloonView.frame)) {
            GraphView *gv = [self.visibleResults objectForKey:[NSNumber numberWithInt:self.dateBalloonView.index]];
            
            if (gv.point.y - 74.0 < -4) {
                self.dateBalloonView.frame = CGRectMake(self.dateBalloonView.frame.origin.x, gv.point.y + 10.0, self.dateBalloonView.frame.size.width, self.dateBalloonView.frame.size.height);
                self.dateBalloonView.transform = CGAffineTransformMakeRotation(M_PI);
                self.dateBalloonView.textLabel.transform = CGAffineTransformMakeRotation(M_PI);
            }
            else {
                self.dateBalloonView.frame = CGRectMake(self.dateBalloonView.frame.origin.x, gv.point.y - 74.0, self.dateBalloonView.frame.size.width, self.dateBalloonView.frame.size.height);
                self.dateBalloonView.transform = CGAffineTransformMakeRotation(0);
                self.dateBalloonView.textLabel.transform = CGAffineTransformMakeRotation(0);
            }
        }
        
        [UIView commitAnimations];
    }
    
    if (examStat) {
        CGFloat current_y = INNER_HEIGHT - Y_DELTA * [examStat.faultyPoints floatValue] - 33.0;
        current_y = current_y < 0.0 ? 0.0 : current_y;
        
        GraphView *graphView = [[GraphView alloc] initWithFrame:CGRectMake(x_delta * index + START_OFFSET, current_y, 36.0, 46.0) andExamStatistic:examStat andIndex:index];
        graphView.delegate = self;
        [self.chartScrollView addSubview:graphView];
        [self.visibleResults setObject:graphView forKey:@(index)];

        
        NSString *month = [self.monthFormatter stringFromDate:examStat.date];
        NSString *dateStr = [NSString stringWithFormat:@"%f", [examStat.date timeIntervalSinceReferenceDate]];
        if (![self.visibleMonthIndicators objectForKey:month] && [self.datesForMonthIndicators containsObject:dateStr]) {
            MonthIndicatorLabel *monthIndicator = [[MonthIndicatorLabel alloc] initWithFrame:CGRectMake(x_delta * index + START_OFFSET - 4.0, INNER_HEIGHT - 5.0, 40.0, 38.0)];
            monthIndicator.text = month;
            [self.chartScrollView addSubview:monthIndicator];
            [self.visibleMonthIndicators setObject:monthIndicator forKey:month];

        }
    }
}

- (void)addMissingAndRemoveOldGraphViews:(NSUInteger)index
{
    int start = (int)index - 1 >= 0 ? index - 1 : 0;
    int end = [self.examStatistics count] > index + NUM_OF_RESULTS_SHOWN ? index + NUM_OF_RESULTS_SHOWN : [self.examStatistics count] - 1;
    BOOL animate = NO;
    
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[[self.visibleResults allKeys] sortedArrayUsingFunction:intSort2 context:NULL]];
    for (NSNumber *key in keys) {
        
        if ([key intValue] < start || [key intValue] > end) {
            GraphView *gv = nil;
            if ((gv = [self.visibleResults objectForKey:key])) {
                [gv removeFromSuperview];
                [self.visibleResults removeObjectForKey:key];
                animate = YES;
            }
        }
    }
    
    for (int i = start; i <= end; i++) {
        if (![self.visibleResults objectForKey:[NSNumber numberWithInt:i]]) {
            [self addNewGraphView:i];
            animate = NO;
        }
    }
    
    if (animate) {
        ExamStatistic *examStat = [self.examStatistics objectAtIndex:index];
        NSInteger maxFault = [examStat.faultyPoints intValue] > self.maxPoints * 2 ? [examStat.faultyPoints intValue] : self.maxPoints * 2;
        for (GraphView *gv in [self.visibleResults allValues]) {
            maxFault = gv.faults > maxFault ? gv.faults : maxFault;
        }
        
        CGFloat new_y_delta = (INNER_HEIGHT - 32.0) / [[NSNumber numberWithInt:maxFault] floatValue];
        if (Y_DELTA != new_y_delta) {
            Y_DELTA = new_y_delta;
            
            CATransition *anim = [CATransition animation];
            [anim setType:kCATransitionFade];
            [anim setSubtype:kCATransitionFromTop];
            [anim setDuration:0.15];
            [self.graphOfAFunctionView.layer addAnimation:anim forKey:@""];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            // Move points
            for (GraphView *gv in [self.visibleResults allValues]) {
                CGFloat current_y = INNER_HEIGHT - Y_DELTA * [[NSNumber numberWithInt:gv.faults] floatValue] - 33.0;
                gv.frame = CGRectMake(gv.frame.origin.x, current_y, 36.0, 46.0);
            }
            
            // Move balloon
            CGRect rect = CGRectMake(self.chartScrollView.contentOffset.x, self.chartScrollView.contentOffset.y,
                                     self.chartScrollView.frame.size.width,self.chartScrollView.frame.size.height);
            if (CGRectIntersectsRect(rect, self.dateBalloonView.frame)) {
                GraphView *gv = [self.visibleResults objectForKey:[NSNumber numberWithInt:self.dateBalloonView.index]];
                
                if (gv.point.y - 74.0 < -4) {
                    self.dateBalloonView.frame = CGRectMake(self.dateBalloonView.frame.origin.x, gv.point.y + 10.0, self.dateBalloonView.frame.size.width, self.dateBalloonView.frame.size.height);
                    self.dateBalloonView.transform = CGAffineTransformMakeRotation(M_PI);
                    self.dateBalloonView.textLabel.transform = CGAffineTransformMakeRotation(M_PI);
                }
                else {
                    self.dateBalloonView.frame = CGRectMake(self.dateBalloonView.frame.origin.x, gv.point.y - 74.0, self.dateBalloonView.frame.size.width, self.dateBalloonView.frame.size.height);
                    self.dateBalloonView.transform = CGAffineTransformMakeRotation(0);
                    self.dateBalloonView.textLabel.transform = CGAffineTransformMakeRotation(0);
                }
            }
            
            [UIView commitAnimations];
        }
    }
    
    [self.graphOfAFunctionView setNeedsDisplay];
}

- (void)closeModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/
@end
