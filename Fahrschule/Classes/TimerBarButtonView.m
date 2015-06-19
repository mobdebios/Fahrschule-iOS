//
//  TimerBarButtonView.m
//  Fahrschule
//
//  Created by Johan Olsson on 02.05.11.
//  Copyright 2011 freenet. All rights reserved.
//

#import "TimerBarButtonView.h"


@implementation TimerBarButtonView

@synthesize timeLeftLabel=_timeLeftLabel;
@synthesize timeLeftImageView=_timeLeftImageView;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 59.0, 30.0)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _timeLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(34.0, 0.0, 25.0, 30.0)];
        self.timeLeftLabel.font = [UIFont boldSystemFontOfSize:22.0];
        self.timeLeftLabel.backgroundColor = [UIColor clearColor];
        self.timeLeftLabel.textColor = [UIColor whiteColor];
        self.timeLeftLabel.textAlignment = NSTextAlignmentRight;
        
        _timeLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
        self.timeLeftImageView.image = [UIImage imageNamed:@"icon_uhr.png"];
        self.timeLeftImageView.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self addSubview:self.timeLeftLabel];
    [self addSubview:self.timeLeftImageView];
}

@end
