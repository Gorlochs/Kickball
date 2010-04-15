//
//  TwActivityIndicator.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 11/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwActivityIndicator : UIView {
@private
    UIActivityIndicatorView *_indicator;
    UILabel                 *_messageLabel;
}

@property (nonatomic, readonly) UILabel *messageLabel;

- (void)show;

- (void)showInView:(UIView*)view;

- (void)showInRect:(CGRect)rect;

- (void)hide;

@end
