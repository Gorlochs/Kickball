//
//  KBFacebookListViewController.h
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFacebookViewController.h"

@class KBFacebookLoginView;
@interface KBFacebookListViewController : KBFacebookViewController{
	KBFacebookLoginView *fbLoginView;
	BOOL doingLogin;
	NSArray *newsFeed;
}

-(void)showLoginView;
-(void)killLoginView;
-(void)refreshMainFeed;
@end
