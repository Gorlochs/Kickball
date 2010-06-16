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
#import "FoursquareAPI.h"
#import "SBJSON.h"
    
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
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsToPingReceived:) name:@"friendPingRetrievalComplete" object:nil];
		DLog("push notification notification has been activated!");
    }
    return self;
}

// FIXME: this will have to use a caching system eventually
- (void) sendPushNotification {
//    if ([[Utilities sharedInstance] friendsWithPingOn]) {
//        DLog(@"friends with ping on pulled from cache: %@", [[[Utilities sharedInstance] friendsWithPingOn] componentsJoinedByString:@","]);
        [self retrieveAllFriendsWithPingOn];
//    } else {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsToPingReceived:) name:@"friendsWithPingOnReceived" object:nil];
//    }
}

- (void) retrieveAllFriendsWithPingOn {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gorlochs.literalshore.com:3000/kickball/pings/user/%@.json", 
                                       [[FoursquareAPI sharedInstance] currentUser].userId]];
    ASIHTTPRequest *gorlochRequest = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    
    [gorlochRequest setDidFailSelector:@selector(pingRequestWentWrong:)];
    [gorlochRequest setDidFinishSelector:@selector(pingRequestDidFinish:)];
    [gorlochRequest setTimeOutSeconds:500];
    [gorlochRequest setDelegate:self];
    [gorlochRequest startAsynchronous];
}

- (void) pingRequestWentWrong:(ASIHTTPRequest *) request {
    DLog(@"BOOOOOOOOOOOO!");
}

- (void) pingRequestDidFinish:(ASIHTTPRequest *) request {
    DLog("ping request finished: %@", [request responseString]);
    [Utilities sharedInstance].userIdsToReceivePings = [[NSMutableArray alloc] initWithCapacity:1];
    SBJSON *parser = [[SBJSON new] autorelease];
    id pingArray = [parser objectWithString:[request responseString] error:NULL];
    for (NSDictionary *dict in (NSArray*)pingArray) {
        [[Utilities sharedInstance].userIdsToReceivePings addObject:[[dict objectForKey:@"ping"] objectForKey:@"userId"]];
    }
    // I could include the array into the userInfo, but that array is available through the singleton anyway
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"friendPingRetrievalComplete" object:self userInfo:nil];
	[self friendsToPingReceived];
}

- (void)friendsToPingReceived {
    
    NSMutableArray *friendIds = [[[Utilities sharedInstance] userIdsToReceivePings] retain];
//    for (FSUser* friend in [[Utilities sharedInstance] friendsWithPingOn]) {
//        [friendIds addObject:friend.userId];
//    }
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
		[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"friendPingRetrievalComplete"];
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
