//
//  KBFacebookListViewController.h
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFacebookViewController.h"
#import "Three20/Three20.h"

@class KBFacebookLoginView, GraphObject;
@interface KBFacebookListViewController : KBFacebookViewController{
	BOOL doingLogin;
	NSArray *newsFeed;
	TTStyledTextLabel *heightTester;
	NSString *nextPageURL;
	BOOL requeryWhenTableGetsToBottom;

}


-(void)refreshMainFeed;
-(void)delayedRefresh;
//-(void)concatenateMore;
-(NSString*)findSuitableText:(GraphObject*)fbItem;
-(void)concatenateMore:(NSString*)urlString;

-(IBAction)createPost;
@end
