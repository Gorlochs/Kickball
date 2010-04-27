//
//  KBShoutViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBShoutViewController.h"
#import "FoursquareAPI.h"
#import "KBMessage.h"
#import "Beacon.h"
#import "NSString+hmac.h"
#import "MPOAuthSignatureParameter.h"
#import "FriendsListViewController.h"


@implementation KBShoutViewController

@synthesize venueId;
@synthesize isCheckin;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    [theTextView becomeFirstResponder];
    theTextView.font = [UIFont fontWithName:@"Georgia" size:12.0];
    
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
        [theTextView resignFirstResponder];
        [self startProgressBar:@"Shouting..."];
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
        [theTextView resignFirstResponder];
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
    
    self.shoutToPush = [NSString stringWithString:theTextView.text];
    [self sendPushNotification];
    [self closeUpShop];
}

- (void) closeUpShop {
    [self stopProgressBar];
    [self cancelView];
}

#pragma mark 
#pragma mark UITextViewDelegate methods

- (void) textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 140) {
        textView.text = [textView.text substringToIndex:139];
    }
    characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [textView.text length]];
}

#pragma mark 
#pragma mark memory management methods

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
