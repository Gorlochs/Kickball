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
#import "MD5.h"
#import "Utilities.h"

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
    
    FSUser *user = [[FoursquareAPI sharedInstance] currentUser];
    NSString *uid = user.userId;
    NSString *un = [user.firstnameLastInitial stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *shout = [theTextView.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *hashInput = [NSString stringWithFormat:@"%@%@%@%@", uid, un, shout, kKBHashSalt];
    NSString *hash = [NSString md5: hashInput];
    NSString *urlstring = [NSString stringWithFormat:
                           @"https://www.gorlochs.com/kickball/push.php?shout=%@&uid=%@&un=%@&ck=%@", shout, uid, un, hash];
    NSLog(@"urlstring: %@", urlstring);
    
    NSString *push = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlstring]];
    NSLog(@"push: %@", push);
    
    // TODO: confirm that the shout was sent?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutSent"
                                                        object:nil
                                                      userInfo:nil];
    [self cancelView];
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
