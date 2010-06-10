//
//  InstructionView.m
//  Kickball
//
//  Created by Shawn Bernard on 12/8/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "InstructionView.h"


@implementation InstructionView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    //[removeViewButton release];
    [super dealloc];
}

- (void) removeView {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:@"viewedInstructions"];
    [self removeFromSuperview];
}


@end
