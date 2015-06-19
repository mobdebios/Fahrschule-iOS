//
//  GraphDiagramController.h
//  Fahrschule
//
//  Created by Johan Olsson on 19.05.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "FahrschuleViewController.h"
//#import "BalloonView.h"
//#import "GraphView.h"
//#import "GraphOfAFunctionView.h"


//@interface GraphDiagramController : FahrschuleViewController <GraphViewDelegate, GraphOfAFunctionViewDelegate> {
//    
//}

//@interface GraphDiagramController : FahrschuleViewController <GraphViewDelegate>

@interface GraphDiagramController : UIViewController

@property (nonatomic, retain) IBOutlet UIScrollView *chartScrollView;
//@property (nonatomic, retain) IBOutlet GraphOfAFunctionView *graphOfAFunctionView;
//@property (nonatomic, retain) IBOutlet BalloonView *dateBalloonView;

@property (nonatomic, retain) IBOutlet UIView *graphOfAFunctionView;
@property (nonatomic, retain) IBOutlet UIView *dateBalloonView;

@property (nonatomic, assign) NSUInteger maxPoints;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSDateFormatter *monthFormatter;
@property (nonatomic, retain) NSArray *examStatistics;
@property (nonatomic, retain) NSArray *datesForMonthIndicators;
@property (nonatomic, retain) NSMutableDictionary *visibleMonthIndicators;
@property (nonatomic, retain) NSMutableDictionary *visibleResults;

- (void)addNewGraphView:(NSUInteger)index;
- (void)addMissingAndRemoveOldGraphViews:(NSUInteger)index;
- (void)closeModalView:(id)sender;

@end
