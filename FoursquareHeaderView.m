//
//  FoursquareHeaderView.m
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FoursquareHeaderView.h"


@implementation FoursquareHeaderView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
//        backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 30, 25)];
        
//        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        backButton.frame = CGRectMake(0, 0, 23, 23);
//        //myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        //myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//        
//        // Set the image for the button
//        [backButton setImage:[UIImage imageNamed:@"btn-4sqMap01.png"] forState:UIControlStateNormal];
//        [backButton addTarget:self action:@selector(backOneView) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:backButton];
    }
    return self;
}

//- (void) backOneView {
//    DLog(@"*************** BACK ONE VIEW ***************");
//    //[self.parentViewController.navigationController popViewControllerAnimated:YES];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
