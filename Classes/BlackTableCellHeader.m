//
//  BlackTableCellHeader.m
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "BlackTableCellHeader.h"


@implementation BlackTableCellHeader

@synthesize leftHeaderLabel;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        
        leftHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 4.0, 150.0, 24.0)];
        leftHeaderLabel.backgroundColor = [UIColor clearColor];
        leftHeaderLabel.opaque = NO;
        leftHeaderLabel.textColor = [UIColor grayColor];
        leftHeaderLabel.highlightedTextColor = [UIColor whiteColor];
        leftHeaderLabel.font = [UIFont boldSystemFontOfSize:11];
//        leftHeaderLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
//        leftHeaderLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:leftHeaderLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [leftHeaderLabel release];
    [super dealloc];
}


@end
