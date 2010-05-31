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
#import "FlurryAPI.h"
#import "NSString+hmac.h"
#import "MPOAuthSignatureParameter.h"
#import "FriendsListViewController.h"
#import "FSUser.h"
#import "KBTwitterManager.h"
#import "KBLocationManager.h"


@implementation KBShoutViewController

@synthesize venueId;
@synthesize isCheckin;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.twitterEngine = [[KBTwitterManager twitterManager] twitterEngine];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    [theTextView becomeFirstResponder];
    theTextView.font = [UIFont fontWithName:@"Georgia" size:12.0];
    
    FSUser* user = [self getAuthenticatedUser];
    facebookButton.enabled = user.facebook != nil;
    twitterButton.enabled = user.twitter != nil;
    isFacebookOn = facebookButton.enabled;
    isTwitterOn = twitterButton.enabled;
    
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

#pragma mark -
#pragma mark IBActions

- (void) toggleTwitter {
    if (isTwitterOn) {
        [twitterButton setImage:[UIImage imageNamed:@"tw02.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"tw03.png"] forState:UIControlStateHighlighted];
    } else {
        [twitterButton setImage:[UIImage imageNamed:@"tw01.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"tw04.png"] forState:UIControlStateHighlighted];
    }
    isTwitterOn = !isTwitterOn;
}

- (void) toggleFacebook {
    if (isFacebookOn) {
        [facebookButton setImage:[UIImage imageNamed:@"fb02.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"fb03.png"] forState:UIControlStateHighlighted];
    } else {
        [facebookButton setImage:[UIImage imageNamed:@"fb01.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"fb04.png"] forState:UIControlStateHighlighted];
    }
    isFacebookOn = !isFacebookOn;
}

- (void) toggleFoursquare {
    if (isFoursquareOn) {
        [foursquareButton setImage:[UIImage imageNamed:@"fb02.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"fb03.png"] forState:UIControlStateHighlighted];
    } else {
        [foursquareButton setImage:[UIImage imageNamed:@"fb01.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"fb04.png"] forState:UIControlStateHighlighted];
    }
    isFoursquareOn = !isFoursquareOn;
}

#pragma mark -
#pragma mark shout related methods

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
        actionCount = 1 + isTwitterOn + isFacebookOn;
        
        [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil 
                                                      andShout:theTextView.text 
                                                       offGrid:NO
                                                     toTwitter:NO
                                                    toFacebook:NO 
                                                    withTarget:self 
                                                     andAction:@selector(shoutResponseReceived:withResponseString:)];
        
        // we send twitter/facebook api calls ourself so that the tweets and posts are stamped with the Kickball brand
        
        if (isTwitterOn) {
            // TODO: check for twitter login
            [self.twitterEngine sendUpdate:theTextView.text
                              withLatitude:[[KBLocationManager locationManager] latitude] 
                             withLongitude:[[KBLocationManager locationManager] longitude]];
        }
        
        if (isFacebookOn) {
            // TODO: check for facebook login
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:theTextView.text, @"status", nil];
            [[FBRequest requestWithDelegate:self] call:@"facebook.status.set" params:params dataParam:nil];
        }
        
        [FlurryAPI logEvent:@"Shout"];
    } else {
        NSLog(@"no text in shout field");
    }
}

// Twitter response
- (void) statusRetrieved:(NSNotification *)inNotification {
    [self decrementActionCount];
}

// Facebook response
- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([request.method isEqualToString:@"facebook.status.set"]) {
        NSDictionary* info = result;
        NSLog(@"facebook status updated: %@", info);
    }
    [self decrementActionCount];
}

// 4sq response
- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	NSArray *shoutCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    
    self.shoutToPush = [NSString stringWithString:theTextView.text];
    [self sendPushNotification];
    
    [self decrementActionCount];
}

- (void) decrementActionCount {
    actionCount--;
    if (actionCount == 0) {
        [self closeUpShop];
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
