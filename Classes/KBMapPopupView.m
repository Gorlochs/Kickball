//
//  KBMapPopupView.m
//  Kickball
//
//  Created by Shawn Bernard on 5/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBMapPopupView.h"


@implementation KBMapPopupView

@synthesize screenname;
@synthesize tweetText;
@synthesize userIcon;

//- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithFrame:frame])) {
//        // Initialization code        
//    }
//    return self;
//}

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        /* class-specific initialization goes here */
//        tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(8, 29, 250, 50)];
//        tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
//        tweetText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
//        tweetText.backgroundColor = [UIColor clearColor];
//        tweetText.linksEnabled = YES;
//        tweetText.numberOfLines = 0;
//        [self addSubview:tweetText];
//    }
//    return self;
//}

//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/

- (void)dealloc {
	[screenname release];
	[tweetText release];
	[userIcon release];
    [super dealloc];
}


@end
