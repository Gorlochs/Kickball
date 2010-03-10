//
//  KBTextViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTextViewController.h"
#import "FoursquareAPI.h"
#import "KBMessage.h"
#import "Beacon.h"
#import "NSString+hmac.h"
#import "MPOAuthSignatureParameter.h"
#import "Utilities.h"
#import "ASIFormDataRequest.h"
#import "FriendsListViewController.h"


@implementation KBTextViewController

@synthesize venueId;
@synthesize isCheckin;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [theTextView becomeFirstResponder];
    
    if (isCheckin) {
        nonCheckinView.hidden = YES;
        checkinView.hidden = NO;
    } else {
        nonCheckinView.hidden = NO;
        checkinView.hidden = YES;
    }
}

- (void) cancelView {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) shoutAndCheckin {
    
    if ([theTextView.text length] > 0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:theTextView.text, @"NO", nil] forKeys:[NSArray arrayWithObjects:@"shout", @"isTweet", nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutAndCheckinSent"
                                                            object:nil
                                                          userInfo:userInfo];	
        [self cancelView];
    } else {
        
    }
}

- (void) shout {
    if ([theTextView.text length] > 0) {
        [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil 
                                                      andShout:theTextView.text 
                                                       offGrid:NO
                                                     toTwitter:NO
                                                    withTarget:self 
                                                     andAction:@selector(shoutResponseReceived:withResponseString:)];
        [[Beacon shared] startSubBeaconWithName:@"Shout"];
    } else {
        NSLog(@"no text in shout field");
    }
}

- (void) shoutAndTweet {
    if ([theTextView.text length] > 0) {
        [self startProgressBar:@"Shouting and tweeting..."];
        [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil 
                                                      andShout:theTextView.text 
                                                       offGrid:NO
                                                     toTwitter:YES
                                                    withTarget:self 
                                                     andAction:@selector(shoutResponseReceived:withResponseString:)];
        [[Beacon shared] startSubBeaconWithName:@"Shout"];
    } else {
        NSLog(@"no text in shout field");
    }
}

- (void) shoutAndTweetAndCheckin {
    if ([theTextView.text length] > 0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:theTextView.text, @"YES", nil] forKeys:[NSArray arrayWithObjects:@"shout", @"isTweet", nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutAndCheckinSent"
                                                            object:nil
                                                          userInfo:userInfo];	
        [self cancelView];
    } else {
        
    }
}

- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	NSArray *shoutCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    NSLog(@"shoutCheckins: %@", shoutCheckins);
    [self stopProgressBar];
    
    // TODO: make this asynchronous
    if ([[Utilities sharedInstance] friendsWithPingOn]) {
        NSLog(@"friends with ping on pulled from cache: %@", [[[Utilities sharedInstance] friendsWithPingOn] componentsJoinedByString:@","]);
        [self friendsReceived:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsReceived:) name:@"friendsWithPingOnReceived" object:nil];
    }
}

- (void)friendsReceived:(NSNotification *)inNotification {
    
    NSMutableArray *friendIds = [[NSMutableArray alloc] initWithCapacity:1];
    for (FSUser* friend in [[Utilities sharedInstance] friendsWithPingOn]) {
        [friendIds addObject:friend.userId];
    }
    NSString *friendIdsString = [friendIds componentsJoinedByString:@","];
    [friendIds release];
    
    FSUser *user = [[FoursquareAPI sharedInstance] currentUser];
    NSString *uid = user.userId;
    NSString *un = user.firstnameLastInitial;
    NSString *shout = theTextView.text;
	NSString *hashInput = [NSString stringWithFormat:@"%@%@%@", uid, un, shout];
    NSString *hash = [hashInput hmacSha1:kKBHashSalt];
    NSString *urlstring = @"https://www.gorlochs.com/kickball/push.php";
	
	NSURL *url = [NSURL URLWithString:urlstring];
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
	[request setPostValue:shout forKey:@"shout"];
	[request setPostValue:uid forKey:@"uid"];
	[request setPostValue:un forKey:@"un"];
	[request setPostValue:friendIdsString forKey:@"fids"];
	[request setPostValue:hash forKey:@"ck"];
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(pushCompleted:)];
	[request setDidFailSelector: @selector(pushFailed:)];
	[queue addOperation:request];
    
    [self cancelView];
}

- (void)pushCompleted:(ASIHTTPRequest *) request {
	NSString *result = request.responseString;
	NSLog(@"Response from push: %@", result);
	
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutSent"
                                                        object:nil
                                                      userInfo:nil];	
}

- (void)pushFailed:(ASIHTTPRequest *) request {
	NSString *result = request.responseString;
	NSLog(@"Failure from push: %@", result);
	
	//TODO: Alert user to failure
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [theTextView release];
    [venueId release];
    [checkinView release];
    [nonCheckinView release];
    [super dealloc];
}

@end
