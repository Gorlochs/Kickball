//
//  MyTweetViewController.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/10/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGTwitterEngine;

#import "MessageListController.h"

@interface MyTweetViewController : MessageListController
{
	UIBarButtonItem *_topBarItem;
}

- (void)changeActionSegment:(id)sender;

@end
