//
//  KBCreateTweetViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBCreateTweetViewController.h"
#import "Three20/Three20.h"
#import "KBLocationManager.h"
#import "FoursquareAPI.h"
#import "PhotoMessageViewController.h"
#import "KBAccountManager.h"

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
    
    photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
    
    // TODO: need to enable/disable buttons depending on whether or not the user signed in
}

#pragma mark -
#pragma mark IBAction methods

- (void) submitTweet {
    
    [self startProgressBar:@"Submitting..."];
    [self dismissModalViewControllerAnimated:YES];
    actionCount = 1 + isFoursquareOn + isFacebookOn + photoImage != nil;
    
    // TODO: add shortened url to tweet, if there is a photo, which means all this will have to be reordered
    // http://api.bit.ly/v3/shorten?login=sabernar&apiKey=R_fc7cbaa3eccbd1597f18412c9774a351&format=json&longUrl=http%3A%2F%2Fbetaworks.com%2F
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
    
    if (isFacebookOn && [[KBAccountManager sharedInstance] usesFacebook]) {
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
    
    if (photoImage) {
        [photoManager uploadImage:UIImageJPEGRepresentation(photoImage, 1.0) 
                         filename:@"tweet.jpg" 
                        withWidth:photoImage.size.width 
                        andHeight:photoImage.size.height
                       andMessage:tweetTextView.text
                   andOrientation:photoImage.imageOrientation
                         andVenue:nil];
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

#pragma mark -
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
        [[Beacon shared] startSubBeaconWithName:@"Choose Photo: Library"];
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [[Beacon shared] startSubBeaconWithName:@"Choose Photo: New"];
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }
}

#pragma mark -
#pragma mark Image Picker Delegate methods

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
    [[Beacon shared] startSubBeaconWithName:@"Image Upload Completed"];
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
    [thumbnailPreview release];
    [super dealloc];
}


@end
