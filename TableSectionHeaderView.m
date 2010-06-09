//
//  TableSectionHeaderView.m
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "TableSectionHeaderView.h"


@implementation TableSectionHeaderView

@synthesize leftHeaderLabel;
@synthesize rightHeaderLabel;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code	
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        
        leftHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 4.0, 200.0, 24.0)];
        leftHeaderLabel.backgroundColor = [UIColor clearColor];
        leftHeaderLabel.opaque = NO;
        leftHeaderLabel.textColor = [UIColor grayColor];
        leftHeaderLabel.highlightedTextColor = [UIColor whiteColor];
        leftHeaderLabel.font = [UIFont boldSystemFontOfSize:11];
        leftHeaderLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        leftHeaderLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:leftHeaderLabel];
        
        rightHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 4.0, 100.0, 24.0)];
        rightHeaderLabel.backgroundColor = [UIColor clearColor];
        rightHeaderLabel.opaque = NO;
        rightHeaderLabel.textColor = [UIColor grayColor];
        rightHeaderLabel.highlightedTextColor = [UIColor whiteColor];
        rightHeaderLabel.font = [UIFont boldSystemFontOfSize:11];
        rightHeaderLabel.textAlignment = UITextAlignmentRight; 
        rightHeaderLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        rightHeaderLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:rightHeaderLabel];
        
        topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        topLineImage.frame = CGRectMake(0, 0, self.frame.size.width, 1);
        [self addSubview:topLineImage];
        
        // TODO: the origin.y should probably not be hard coded
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        bottomLineImage.frame = CGRectMake(0, 29, self.frame.size.width, 1);
        [self addSubview:bottomLineImage];
    }
    return self;
}

- (void)dealloc {
    [leftHeaderLabel release];
    [rightHeaderLabel release];
    [topLineImage release];
    [bottomLineImage release];
    [super dealloc];
}


@end
