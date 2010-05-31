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
#import "FlurryAPI.h"
#import "NSString+hmac.h"
#import "MPOAuthSignatureParameter.h"
#import "FriendsListViewController.h"
#import "FSUser.h"
#import "KBTwitterManager.h"
#import "KBLocationManager.h"
#import "KBAccountManager.h"


@implementation KBCheckinModalViewController

@synthesize venue;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    hideHeader = YES;
    hideFooter = YES;
    
    self.twitterEngine = [[KBTwitterManager twitterManager] twitterEngine];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    
    photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
    
    FSUser* user = [self getAuthenticatedUser];
    NSLog(@"user: %@", user);
    facebookButton.enabled = user.facebook != nil;
    twitterButton.enabled = user.twitter != nil;
    isFacebookOn = YES;
    isTwitterOn = YES;
    isFoursquareOn = YES;
    // hack
    if (![[KBAccountManager sharedInstance] usesFacebook]) {
        facebookButton.enabled = NO;
    } else {
        if (!user.sendToFacebook) {
            [self toggleFacebook];
        }
    }   
    if (![[KBAccountManager sharedInstance] usesTwitter]) {
        twitterButton.enabled = NO;
    } else {
        if (!user.sendToTwitter) {
            [self toggleTwitter];
        }
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

- (void) checkin {
    [checkinTextField resignFirstResponder];
    [self startProgressBar:@"Checking in..."];
    actionCount = 1 + isTwitterOn + isFacebookOn;
    
    [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
                                                  andShout:checkinTextField.text 
                                                   offGrid:!isFoursquareOn
                                                 toTwitter:NO
                                                toFacebook:NO 
                                                withTarget:self 
                                                 andAction:@selector(checkinResponseReceived:withResponseString:)];
    
    // we send twitter/facebook api calls ourself so that the tweets and posts are stamped with the Kickball brand
    if (isTwitterOn) {
        NSString *tweetString = nil;
        if (![checkinTextField.text isEqualToString:@""]) {
            tweetString = [NSString stringWithFormat:@"%@ (just checked into %@) #kb", checkinTextField.text, venue.name];
        } else {
            tweetString = [NSString stringWithFormat:@"I just checked into %@. #kb", venue.name];
        }

        [self.twitterEngine sendUpdate:tweetString
                          withLatitude:[[KBLocationManager locationManager] latitude] 
                         withLongitude:[[KBLocationManager locationManager] longitude]];
    }
    
    if (isFacebookOn) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:checkinTextField.text, @"status", nil];
        [[FBRequest requestWithDelegate:self] call:@"facebook.status.set" params:params dataParam:nil];
    }
    
    // FIXME: ******** ADD VENUE TO THE METHOD CALL ********
    if (photoImage) {
        [photoManager uploadImage:UIImageJPEGRepresentation(photoImage, 1.0) 
                         filename:@"tweet.jpg" 
                        withWidth:photoImage.size.width 
                        andHeight:photoImage.size.height
                       andMessage:checkinTextField.text
                   andOrientation:photoImage.imageOrientation
                         andVenue:venue];
    }
    
    [FlurryAPI logEvent:@"checked in"];
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
//	NSArray *checkins = [FoursquareAPI checkinsFromResponseXML:inString];
//    if ([checkins count] > 0) {
//        checkin = [checkins objectAtIndex:0];
//        NSLog(@"checkin: %@", checkin);
//    }
    checkin = [FoursquareAPI checkinFromResponseXML:inString];
    
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
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [FlurryAPI logEvent:@"Choose Photo: Library"];
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [FlurryAPI logEvent:@"Choose Photo: New"];
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }
}

#pragma mark -
#pragma mark photo related methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:NO];
    
    UIImage *initialImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    float initialHeight = initialImage.size.height;
    float initialWidth = initialImage.size.width;
    
    float ratio = 1.0f;
    if (initialHeight > initialWidth) {
        ratio = initialHeight/initialWidth;
    } else {
        ratio = initialWidth/initialHeight;
    }
    NSString *roundedFloatString = [NSString stringWithFormat:@"%.1f", ratio];
    float roundedFloat = [roundedFloatString floatValue];
    
    photoImage = [[photoManager imageByScalingToSize:initialImage toSize:CGSizeMake(480.0, round(480.0/roundedFloat))] retain];
    
    thumbnailPreview.clipsToBounds = YES;
    thumbnailPreview.image = [photoImage retain];
    
    NSLog(@"image picker info: %@", info);
}

- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void) choosePhotoSelectMethod {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"How would you like to select a photo?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Photo Album", @"Take New Photo", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void) photoUploadFinished:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"YAY! Image uploaded!");
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
    [self displayPopupMessage:message];
    [message release];
    
    //    CGRect frame = CGRectMake(300, 50, 25, 25);
    //    TTImageView *thumbnail = [[[TTImageView alloc] initWithFrame:frame] autorelease];
    //    thumbnail.backgroundColor = [UIColor clearColor];
    //    NSString *uuid = [[((NSDictionary*)[request responseString]) objectForKey:@"gift"] objectForKey:@"uuid"];
    //    thumbnail.urlPath = [NSString stringWithFormat:@"http://s3.amazonaws.com/kickball/photos/%@/thumb/%@.jpg", uuid, uuid];
    //    //thumbnail.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    //    [self.view addSubview:thumbnail];
    
    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
    [FlurryAPI logEvent:@"Image Upload Completed"];
}

- (void) photoQueueFinished:(ASIHTTPRequest *) request {
    [self decrementActionCount];
    
    NSLog(@"YAY! Image queue is complete!");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    //[self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    NSLog(@"Uhoh, it did fail!");
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
    [venue release];
    [characterCountLabel release];
    [twitterButton release];
    [facebookButton release];
    [foursquareButton release];
    [checkinButton release];
    [checkinTextField release];
    [twitterEngine release];
    [photoManager release];
    [thumbnailPreview release];
    [super dealloc];
}

@end
