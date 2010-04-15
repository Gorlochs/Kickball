//
//  TwActivityIndicator.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 11/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "TwActivityIndicator.h"

@implementation TwActivityIndicator

@synthesize messageLabel = _messageLabel;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.shadowColor = [UIColor blackColor];
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:_indicator];
        [self addSubview:_messageLabel];
    }
    return self;
}

- (void)dealloc 
{
    [_indicator release];
    [_messageLabel release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect 
{
    float radius = 5.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextSetGrayFillColor(context, 0, 0.8);
    CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
    CGContextFillPath(context);
    CGContextClosePath(context);
    CGContextClip(context);
}

- (void)resize:(CGRect)parentRect
{
    CGRect selfFrame, myRect;
    
    selfFrame = self.frame;
    
    int messageLabelRowCount = 1;
    if (selfFrame.size.width >= 320) 
    {
        selfFrame.size.width = 320 * 2 / 3;
        selfFrame.size.height += 20;
        messageLabelRowCount++;
    }
    
    myRect.origin.x = (parentRect.size.width - selfFrame.size.width) / 2;
    myRect.origin.y = (parentRect.size.height - selfFrame.size.height) / 2;
    myRect.size.width = selfFrame.size.width;
    myRect.size.height = selfFrame.size.height;
    self.frame = myRect;
    
    CGRect indRect = _indicator.frame;
    
    indRect.origin.x = (myRect.size.width - indRect.size.width) / 2;
    indRect.origin.y = 15;
    _indicator.frame = indRect;
    
    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    _messageLabel.numberOfLines = messageLabelRowCount;
    _messageLabel.frame = CGRectMake(0, indRect.origin.y + indRect.size.height + 5, self.frame.size.width, 20 * messageLabelRowCount);
    _messageLabel.textAlignment = UITextAlignmentCenter;
}

- (void)show
{
    UIWindow *wnd = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [self showInView:wnd];
}

- (void)showInView:(UIView*)view
{
    [self.messageLabel sizeToFit];
    
    CGRect labelFrame = [self.messageLabel frame];
    
    self.frame = CGRectMake(0, 0, (int)labelFrame.size.width + 50, 80);
    
    if (view)
    {
        CGRect parentRect = [view frame];
        
        [self resize:parentRect];
        [_indicator startAnimating];
        [view addSubview:self];
    }
    [self setNeedsDisplay];
}

- (void)showInRect:(CGRect)rect
{
    [self.messageLabel sizeToFit];
    CGRect labelFrame = [self.messageLabel frame];
    self.frame = CGRectMake(0, 0, (int)labelFrame.size.width + 50, 80);
    [self resize:rect];
    [_indicator startAnimating];
    UIWindow *wnd = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [wnd addSubview:self];
    [self setNeedsDisplay];    
}

- (void)hide
{
    [_indicator stopAnimating];
    [self removeFromSuperview];
}

@end
