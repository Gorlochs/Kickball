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


@implementation KBTextViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [theTextView becomeFirstResponder];
}

- (void) cancelView {
    [[Beacon shared] startSubBeaconWithName:@"Cancel Shout"];
    [self dismissModalViewControllerAnimated:YES];
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

- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	NSArray *shoutCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    NSLog(@"shoutCheckins: %@", shoutCheckins);
    
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
    NSString *urlstring = @"http://www.gorlochs.com/kickball/push.php";
	
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
	//[request setDidFailSelector: @selector(requestWentWrong:)];
	[queue addOperation:request];
	
	
	

    
//    NSString *push = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlstring]];
//    NSLog(@"push: %@", push);
    
    // TODO: confirm that the shout was sent?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutSent"
                                                        object:nil
                                                      userInfo:nil];
    [self cancelView];
}

- (void)pushCompleted:(ASIHTTPRequest *) request {
	NSString *result = request.responseString;
	NSLog(@"Response from push: %@", result);
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        [self shout];
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)dealloc {
    [theTextView release];
    [super dealloc];
}

@end
