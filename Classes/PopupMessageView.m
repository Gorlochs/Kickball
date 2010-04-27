//
//  PopupMessageView.m
//  Kickball
//
//  Created by Shawn Bernard on 12/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "PopupMessageView.h"

@interface TextStyleSheet : TTDefaultStyleSheet
@end

@implementation TextStyleSheet

- (TTStyle*)blueText {
    return [TTTextStyle styleWithColor:[UIColor blueColor] next:nil];
}

- (TTStyle*)largeText {
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:32] next:[TTTextStyle styleWithColor:[UIColor whiteColor] next:nil]];
}

- (TTStyle*)smallText {
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12] next:[TTTextStyle styleWithColor:[UIColor whiteColor] next:nil]];
}

- (TTStyle*)whiteText {
    return [TTTextStyle styleWithColor:[UIColor whiteColor] next:nil];
}

- (TTStyle*)floated {
    return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 0, 5, 5)
                               padding:UIEdgeInsetsMake(0, 0, 0, 0)
                               minSize:CGSizeZero position:TTPositionFloatLeft next:nil];
}

- (TTStyle*)blueBox {
    return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6] next:
     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -5, -4, -6) next:
      [TTShadowStyle styleWithColor:[UIColor whiteColor] blur:2 offset:CGSizeMake(1,1) next:
       [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
        [TTSolidBorderStyle styleWithColor:[UIColor grayColor] width:1 next:nil]]]]];
}

- (TTStyle*)inlineBox {
    return 
    [TTSolidFillStyle styleWithColor:[UIColor blueColor] next:
     [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(5,13,5,13) next:
      [TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:1 next:nil]]];
}

- (TTStyle*)inlineBox2 {
    return 
    [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
     [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(5,50,0,50)
                         padding:UIEdgeInsetsMake(0,13,0,13) next:nil]];
}

@end


@implementation PopupMessageView

@synthesize message;

- (id)init {
    if (self = [super init]) {
        [TTStyleSheet setGlobalStyleSheet:[[[TextStyleSheet alloc] init] autorelease]];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    messageLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20.0f, 135.0f, 280.0f, 220.0f)];
    [messageLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [messageLabel setTextColor:[UIColor whiteColor]];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setNumberOfLines:0];
    messageLabel.text = message.message;
    [self.view addSubview:messageLabel];
    
    titleLabel.text = message.mainTitle;
    
    NSLog(@"message: %@", message.message);
    CGSize maximumLabelSize = CGSizeMake(280, 220);
    CGSize expectedLabelSize = [message.message sizeWithFont:messageLabel.font 
                                           constrainedToSize:maximumLabelSize 
                                               lineBreakMode:UILineBreakModeClip]; 
    
    //adjust the label the the new height.
    CGRect newFrame = messageLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    NSLog(@"frame height: %f", self.view.frame.size.height);
    NSLog(@"label height: %f", expectedLabelSize.height);
    newFrame.origin.y = self.view.frame.size.height - expectedLabelSize.height - 20;
    messageLabel.frame = newFrame;
    
    CGRect newTitleFrame = titleLabel.frame;
    newTitleFrame.origin.y = newFrame.origin.y - 50;
    titleLabel.frame = newTitleFrame;
    
    if (message.isError) {
        titleLabel.textColor = [UIColor redColor];
    }
}

- (void)dealloc {
    [TTStyleSheet setGlobalStyleSheet:nil];
    [titleLabel release];
    [messageLabel release];
    [message release];
    [closeButton release];
    [super dealloc];
}

- (void) dismissPopupMessage {
    [self.view removeFromSuperview];
}

@end
