//
//  AbstractPushNotificationViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 3/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBBaseViewController.h"
#import "FSVenue.h"

@interface AbstractPushNotificationViewController : KBBaseViewController {
    FSVenue *venueToPush;
    NSString *shoutToPush;
    BOOL hasPhoto;
}

@property (nonatomic, retain) FSVenue *venueToPush;
@property (nonatomic, retain) NSString *shoutToPush;
@property (nonatomic) BOOL hasPhoto;

- (void) sendPushNotification;
- (void) friendsToPingReceived:(NSNotification *)inNotification;

@end
