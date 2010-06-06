//
//  AbstractPushNotificationViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "AbstractPushNotificationViewController.h"
#import "Utilities.h"
#import "ASIFormDataRequest.h"
#import "NSString+hmac.h"
    
//#define PUSH_URL @"https://www.gorlochs.com/kickball/app/push.1.1.php"
#define PUSH_URL @"http://www.literalshore.com/gorloch/kickball/push.1.1.php"

@implementation AbstractPushNotificationViewController

@synthesize shoutToPush;
@synthesize venueToPush;
@synthesize hasPhoto;
@synthesize photoMessageToPush;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void) sendPushNotification {
    if ([[Utilities sharedInstance] friendsWithPingOn]) {
        DLog(@"friends with ping on pulled from cache: %@", [[[Utilities sharedInstance] friendsWithPingOn] componentsJoinedByString:@","]);
        [self friendsToPingReceived:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsToPingReceived:) name:@"friendsWithPingOnReceived" object:nil];
    }
}

- (void)friendsToPingReceived:(NSNotification *)inNotification {
    
    NSMutableArray *friendIds = [[NSMutableArray alloc] initWithCapacity:1];
    for (FSUser* friend in [[Utilities sharedInstance] friendsWithPingOn]) {
        [friendIds addObject:friend.userId];
    }
    NSString *friendIdsString = [friendIds componentsJoinedByString:@","];
    DLog(@"friend ids: %@", friendIdsString);
    [friendIds release];
    
    FSUser *user = [self getAuthenticatedUser];
    NSString *uid = user.userId;
    NSString *un = user.firstnameLastInitial;
    NSString *vn = venueToPush.name;
    NSString *hashInput = nil;
    if (self.shoutToPush && ![self.shoutToPush isEqualToString:@""]) {
        hashInput = [NSString stringWithFormat:@"%@%@%@", uid, un, self.shoutToPush];
    } else {
        hashInput = [NSString stringWithFormat:@"%@%@%@", uid, un, vn];
    }
    DLog(@"hash input: %@", hashInput);
	
    NSString *hash = [hashInput hmacSha1:kKBHashSalt];
    NSString *urlstring = PUSH_URL;
	
	NSURL *url = [NSURL URLWithString:urlstring];
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    if (hasPhoto) {
        [request setPostValue:[NSString stringWithFormat:@"%d", hasPhoto] forKey:@"hasPhoto"];
    }
	[request setPostValue:shoutToPush forKey:@"shout"];
	[request setPostValue:vn forKey:@"vn"];
	[request setPostValue:uid forKey:@"uid"];
	[request setPostValue:un forKey:@"un"];
	[request setPostValue:friendIdsString forKey:@"fids"];
	[request setPostValue:hash forKey:@"ck"];
	[request setPostValue:self.photoMessageToPush forKey:@"photoMessage"];
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(pushCompleted:)];
	[request setDidFailSelector: @selector(pushFailed:)];
	[queue addOperation:request];
}

- (void)pushCompleted:(ASIHTTPRequest *) request {
	NSString *result = request.responseString;
	DLog(@"Response from push: %@", result);
	
    // without the hasPhoto check, the user gets two popup messages, which sucks
    if (!self.venueToPush) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutSent"
                                                            object:nil
                                                          userInfo:nil];
    }
    
    // change hasPhoto to NO just in case a user checks into a venue AFTER uploading a photo
    self.hasPhoto = NO;
}

- (void)pushFailed:(ASIHTTPRequest *) request {
	NSString *result = request.responseString;
	DLog(@"Failure from push: %@", result);
}

- (void) dealloc {
    [shoutToPush release];
    [venueToPush release];
    [photoMessageToPush release];
    [super dealloc];
}

@end
