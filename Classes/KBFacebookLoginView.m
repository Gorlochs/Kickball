//
//  KBFacebookLoginView.m
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookLoginView.h"
#import "KBFacebookListViewController.h"
#import "FacebookProxy.h"
#import "GraphAPI.h"
#import "JSON.h"


@implementation KBFacebookLoginView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setBackgroundColor:[UIColor colorWithWhite:248.0f alpha:0.8f]];
		UIView *roundedRect = [[UIView alloc] initWithFrame:CGRectMake(20, 340, 280, 64)];
		[[roundedRect layer] setCornerRadius:3.0f];
		[roundedRect setBackgroundColor:[UIColor darkGrayColor]];
		[self addSubview:roundedRect];
		[roundedRect release];
		UIButton *fbButt = [UIButton buttonWithType:UIButtonTypeCustom];
		[fbButt setFrame:CGRectMake(73, 366, 176, 31)];
		[fbButt setImage:[UIImage imageNamed:@"login2.png"] forState:UIControlStateNormal];
		[fbButt addTarget:self action:@selector(doAuth) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:fbButt];
		
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

#pragma mark FacebookProxy Callback


-(void)doAuth
{
	//self._statusInfo.text = @"authorizing...";
	[[FacebookProxy instance] loginAndAuthorizeWithTarget:[FacebookProxy instance] callback:@selector(doneAuthorizing)];
}



- (void)dealloc {
    [super dealloc];
}


@end
