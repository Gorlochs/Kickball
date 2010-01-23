//
//  KBPushNotificationView.m
//  Kickball
//
//  Created by Shawn Bernard on 1/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBPushNotificationView.h"


@implementation KBPushNotificationView

@synthesize addressLabel, messageLabel, button;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [UIView setAnimationsEnabled:YES];
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
////    [UIView setAnimationRepeatAutoreverses:YES];
////    [UIView setAnimationRepeatCount:2];
//    [UIView setAnimationDuration:0.50];
//    
////    CGAffineTransform transform1 = CGAffineTransformMakeScale(1.2, 1.2);
////    //CGAffineTransform transform2 = CGAffineTransformMakeScale(-1.2, -1.2);
////    CGAffineTransform transform2 = CGAffineTransformInvert(transform1);
////    CGAffineTransform transform12 = CGAffineTransformConcat(transform1, transform2);
////    self.view.transform = transform12;
//    [UIView commitAnimations];
}

- (void)dealloc {
    [addressLabel release];
    [messageLabel release];
    [button release];
    [super dealloc];
}


@end
