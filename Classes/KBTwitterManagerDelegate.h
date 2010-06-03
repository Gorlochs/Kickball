//
//  KBTwitterManagerDelegate.h
//  Kickball
//
//  Created by Shawn B on 6/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol KBTwitterManagerDelegate

- (void)statusesReceived:(NSArray *)statuses;
- (void)directMessagesReceived:(NSArray *)messages;
- (void)userInfoReceived:(NSArray *)userInfo;
- (void)miscInfoReceived:(NSArray *)miscInfo;
- (void)searchResultsReceived:(NSArray *)searchResults;
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error;

@end
