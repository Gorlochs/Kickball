//
//  AbstractPushNotificationViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 3/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractFacebookViewController.h"
#import "FSVenue.h"

@interface AbstractPushNotificationViewController : AbstractFacebookViewController {
    FSVenue *venueToPush;
    NSString *shoutToPush;
    NSString *photoMessageToPush;
    BOOL hasPhoto;
}

@property (nonatomic, retain) FSVenue *venueToPush;
@property (nonatomic, retain) NSString *shoutToPush;
@property (nonatomic, retain) NSString *photoMessageToPush;
@property (nonatomic) BOOL hasPhoto;

- (void) sendPushNotification;
- (void) friendsToPingReceived:(NSNotification *)inNotification;
- (void) retrieveAllFriendsWithPingOn;
- (void)friendsToPingReceived;

@end
