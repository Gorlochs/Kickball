    //
//  KBCheckinModalViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBCheckinModalViewController.h"
#import "FoursquareAPI.h"
#import "KBMessage.h"
#import "Beacon.h"
#import "NSString+hmac.h"
#import "MPOAuthSignatureParameter.h"
#import "FriendsListViewController.h"
#import "FSUser.h"
#import "KBTwitterManager.h"
#import "KBLocationManager.h"


@implementation KBCheckinModalViewController

@synthesize venueId;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    hideHeader = YES;
    hideFooter = YES;
    
    self.twitterEngine = [[KBTwitterManager twitterManager] twitterEngine];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    
    FSUser* user = [self getAuthenticatedUser];
    NSLog(@"user: %@", user);
    facebookButton.enabled = user.facebook != nil;
    twitterButton.enabled = user.twitter != nil;
    isFacebookOn = YES;
    isTwitterOn = YES;
    isFoursquareOn = YES;
    // hack
    if (!user.sendToFacebook) {
        [self toggleFacebook];
    }
    if (!user.sendToTwitter) {
        [self toggleTwitter];
    }
    actionCount = 0;
}

- (void) cancelView {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IBActions

- (void) toggleTwitter {
    if (isTwitterOn) {
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT02.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT01.png"] forState:UIControlStateHighlighted];
    } else {
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT01.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT02.png"] forState:UIControlStateHighlighted];
    }
    isTwitterOn = !isTwitterOn;
}

- (void) toggleFacebook {
    if (isFacebookOn) {
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB02.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB01.png"] forState:UIControlStateHighlighted];
    } else {
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB01.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB02.png"] forState:UIControlStateHighlighted];
    }
    isFacebookOn = !isFacebookOn;
}

- (void) toggleFoursquare {
    if (isFoursquareOn) {
        // turn 4sq off
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ02.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ01.png"] forState:UIControlStateHighlighted];
    } else {
        // turn 4sq on
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ01.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ02.png"] forState:UIControlStateHighlighted];
    }
    isFoursquareOn = !isFoursquareOn;
}

#pragma mark -
#pragma mark shout related methods

//- (void) shoutAndCheckin {
//    
//    if ([checkinTextField.text length] > 0) {
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:checkinTextField.text, @"NO", nil] 
//                                                             forKeys:[NSArray arrayWithObjects:@"shout", @"isTweet", nil]];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutAndCheckinSent"
//                                                            object:nil
//                                                          userInfo:userInfo];	
//        [self cancelView];
//    } else {
//        
//    }
//}

- (void) checkin {
    if ([checkinTextField.text length] > 0) {
        [checkinTextField resignFirstResponder];
        [self startProgressBar:@"Checking in..."];
        actionCount = 1 + isTwitterOn + isFacebookOn;
        
        [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venueId 
                                                      andShout:checkinTextField.text 
                                                       offGrid:!isFoursquareOn
                                                     toTwitter:NO
                                                    toFacebook:NO 
                                                    withTarget:self 
                                                     andAction:@selector(checkinResponseReceived:withResponseString:)];
        
        // we send twitter/facebook api calls ourself so that the tweets and posts are stamped with the Kickball brand
        if (isTwitterOn) {
            // TODO: check for twitter login
            [self.twitterEngine sendUpdate:checkinTextField.text
                              withLatitude:[[KBLocationManager locationManager] latitude] 
                             withLongitude:[[KBLocationManager locationManager] longitude]];
        }
        
        if (isFacebookOn) {
            // TODO: check for facebook login
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:checkinTextField.text, @"status", nil];
            [[FBRequest requestWithDelegate:self] call:@"facebook.status.set" params:params dataParam:nil];
        }
        
        [[Beacon shared] startSubBeaconWithName:@"checked in"];
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
- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	NSArray *checkins = [FoursquareAPI checkinsFromResponseXML:inString];
    if ([checkins count] > 0) {
        checkin = [checkins objectAtIndex:0];
    }
    
    self.shoutToPush = [NSString stringWithString:checkinTextField.text];
    [self sendPushNotification];
    
    [self decrementActionCount];
}

- (void) decrementActionCount {
    actionCount--;
    if (actionCount == 0) {
        [self closeUpShop];
    }
}

//- (void) shoutAndTweetAndCheckin {
//    if ([checkinTextField.text length] > 0) {
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:checkinTextField.text, @"YES", nil] forKeys:[NSArray arrayWithObjects:@"shout", @"isTweet", nil]];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutAndCheckinSent"
//                                                            object:nil
//                                                          userInfo:userInfo];	
//        [self cancelView];
//    } else {
//        
//    }
//}

- (void) closeUpShop {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:checkin, nil] 
                                                         forKeys:[NSArray arrayWithObjects:@"checkin", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkedIn" object:self userInfo:userInfo];
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
    [venueId release];
    [characterCountLabel release];
    [twitterButton release];
    [facebookButton release];
    [foursquareButton release];
    [checkinButton release];
    [checkinTextField release];
    [twitterEngine release];
    [super dealloc];
}

@end
