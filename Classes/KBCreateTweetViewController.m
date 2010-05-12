//
//  KBCreateTweetViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBCreateTweetViewController.h"
#import "KBLocationManager.h"
#import "FoursquareAPI.h"


@implementation KBCreateTweetViewController

@synthesize replyToStatusId;
@synthesize replyToScreenName;
@synthesize retweetStatusId;
@synthesize retweetToScreenName;
@synthesize retweetTweetText;

- (void)viewDidLoad {
    hideHeader = YES;
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createTweetStatusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    if (self.retweetTweetText) {
        tweetTextView.text = [NSString stringWithFormat:@"RT @%@ %@", self.replyToScreenName, self.retweetTweetText];
    } else if (self.replyToScreenName) {
        tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.replyToScreenName];
    }
    [tweetTextView becomeFirstResponder];
    tweetTextView.font = [UIFont fontWithName:@"Georgia" size:12.0];
    
    isFacebookOn = YES;
    isFoursquareOn = YES;
    
    // FIXME: this is wrong. we need to pull the user's twitter geo settings
    isGeotagOn = YES;
    
    // TODO: need to enable/disable buttons depending on whether or not the user signed in
}

#pragma mark -
#pragma mark IBAction methods

- (void) submitTweet {
    
    [self startProgressBar:@"Submitting..."];
    [self dismissModalViewControllerAnimated:YES];
    actionCount = 1 + isFoursquareOn + isFacebookOn;
    
    if (replyToStatusId && replyToStatusId > 0) {
        if (isGeotagOn) {
            [twitterEngine sendUpdate:tweetTextView.text withLatitude:[[KBLocationManager locationManager] latitude] withLongitude:[[KBLocationManager locationManager] longitude] inReplyTo:[replyToStatusId longLongValue]];
        } else {
            [twitterEngine sendUpdate:tweetTextView.text inReplyTo:[replyToStatusId longLongValue]];
        }
    } else {
        if (isGeotagOn) {
            [twitterEngine sendUpdate:tweetTextView.text withLatitude:[[KBLocationManager locationManager] latitude] withLongitude:[[KBLocationManager locationManager] longitude]];
        } else {
            [twitterEngine sendUpdate:tweetTextView.text];
        }
    }
    
    if (isFacebookOn) {
        NSLog(@"facebook  is on and the status will be updated (hopefully)");
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:tweetTextView.text, @"status", nil];
        [[FBRequest requestWithDelegate:self] call:@"facebook.status.set" params:params dataParam:nil];
    }
    
    if (isFoursquareOn) {
        [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil 
                                                      andShout:tweetTextView.text 
                                                       offGrid:NO
                                                     toTwitter:NO
                                                    toFacebook:NO 
                                                    withTarget:self 
                                                     andAction:@selector(shoutResponseReceived:withResponseString:)];
    }
    
}

- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self decrementActionCount];
}

- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([request.method isEqualToString:@"facebook.status.set"]) {
        NSDictionary* info = result;
        NSLog(@"facebook status updated: %@", info);
    }
    [self decrementActionCount];
}

- (void) cancelCreate {
    [tweetTextView resignFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void) createTweetStatusRetrieved:(NSNotification*)inNotification {
    [self decrementActionCount];
}

- (void) decrementActionCount {
    actionCount--;
    if (actionCount == 0) {
        [self closeUpShop];
    }
}

- (void) closeUpShop {
    [self stopProgressBar];
}

- (void) toggleFoursquare {
    if (isFoursquareOn) {
        // turn 4sq off
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ02.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ01.png"] forState:UIControlStateHighlighted];
    } else {
        // turn 4sq on
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ01.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ02.png"] forState:UIControlStateHighlighted];
    }
    isFoursquareOn = !isFoursquareOn;
}

- (void) toggleFacebook {
    if (isFacebookOn) {
        [facebookButton setImage:[UIImage imageNamed:@"sendFB02.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"sendFB01.png"] forState:UIControlStateHighlighted];
    } else {
        [facebookButton setImage:[UIImage imageNamed:@"sendFB01.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"sendFB02.png"] forState:UIControlStateHighlighted];
    }
    isFacebookOn = !isFacebookOn;
}

- (void) toggleGeotag {
    if (isGeotagOn) {
        [geotagButton setImage:[UIImage imageNamed:@"sendGeo02.png"] forState:UIControlStateNormal];
        [geotagButton setImage:[UIImage imageNamed:@"sendGeo01.png"] forState:UIControlStateHighlighted];
    } else {
        [geotagButton setImage:[UIImage imageNamed:@"sendGeo01.png"] forState:UIControlStateNormal];
        [geotagButton setImage:[UIImage imageNamed:@"sendGeo02.png"] forState:UIControlStateHighlighted];
    }
    isGeotagOn = !isGeotagOn;
}

- (void) addPhoto {
    
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (void) textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 140) {
        textView.text = [textView.text substringToIndex:139];
    }
    characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [textView.text length]];
}

#pragma mark -
#pragma mark memory management methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tweetTextView release];
    [characterCountLabel release];
    [sendTweet release];
    [cancel release];
    
    [replyToStatusId release];
    [replyToScreenName release];
    [retweetStatusId release];
    [retweetToScreenName release];
    
    [foursquareButton release];
    [facebookButton release];
    [geotagButton release];
    [addPhotoButton release];
    [super dealloc];
}


@end
