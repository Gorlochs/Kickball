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
#import "FacebookProxy.h"
#import "GraphAPI.h"
#import "SBJSON.h"

@implementation KBCreateTweetViewController

@synthesize replyToStatusId;
@synthesize replyToScreenName;
@synthesize retweetStatusId;
@synthesize retweetToScreenName;
@synthesize retweetTweetText;
@synthesize directMentionToScreenname;
@synthesize tweetPhoto;

- (void)viewDidLoad {
    hideHeader = NO;
	pageViewType = KBPageViewTypeOther;
	pageType = KBPageTypeOther;
	
    [super viewDidLoad];
	
	// mini-hack to turn off the foursquare button. we might decide to keep it on by default
	//isFoursquareOn = YES; --commented out...  calling the toggle will actually turn it on. so this was actually turning it off.
	isFoursquareOn = ![[KBAccountManager sharedInstance] defaultPostToFoursquare];
	if ([[KBAccountManager sharedInstance] usesFoursquare]) {
		[self toggleFoursquare];
	}else {
		isFacebookOn = NO;
		foursquareButton.enabled = NO;
	}
	
	isFacebookOn = ![[KBAccountManager sharedInstance] defaultPostToFacebook];
	if ([[KBAccountManager sharedInstance] usesFacebook]) {
		[self toggleFacebook];
	}else {
		isFacebookOn = NO;
		facebookButton.enabled = NO;
	}

	//[self toggleFoursquare];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createTweetStatusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    if (self.retweetTweetText) {
        tweetTextView.text = [NSString stringWithFormat:@"RT @%@ %@", self.replyToScreenName, self.retweetTweetText];
    } else if (self.replyToScreenName) {
        tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.replyToScreenName];
    } else if (self.directMentionToScreenname) {
		tweetTextView.text = [NSString stringWithFormat:@"D @%@ ", self.directMentionToScreenname];
	}
    [tweetTextView becomeFirstResponder];
    tweetTextView.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    
    characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [tweetTextView.text length]];
    
    // FIXME: this is wrong. we need to pull the user's twitter geo settings
    isGeotagOn = YES;
    
    photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
    
	/* old logic - changed by scott
	if (![[KBAccountManager sharedInstance] usesFacebook]) {
        facebookButton.enabled = NO;
    } else {
        if (![self getAuthenticatedUser].sendToFacebook || (![self getAuthenticatedUser].facebook && _session.uid)) {
            [self toggleFacebook];
        }
    }
	 */
	
	
	
}

#pragma mark -
#pragma mark IBAction methods

- (void) submitTweet {
    
	[tweetTextView resignFirstResponder];
    [self startProgressBar:@"Submitting..."];
    [self dismissModalViewControllerAnimated:YES];
    actionCount = 1;

    
	/* this is double posting to facebook.   wait and post with the image
    if (isFacebookOn && [[KBAccountManager sharedInstance] usesFacebook]) {
		actionCount++;
        DLog(@"facebook  is on and the status will be updated (hopefully)");
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:tweetTextView.text, @"status", nil];
        [[FBRequest requestWithDelegate:self] call:@"facebook.status.set" params:params dataParam:nil];
    }
	 */
    
    if (isFoursquareOn) {
		actionCount++;
        [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil 
                                                      andShout:tweetTextView.text 
                                                       offGrid:NO
                                                     toTwitter:NO
                                                    toFacebook:NO 
                                                    withTarget:self 
                                                     andAction:@selector(shoutResponseReceived:withResponseString:)];
    }
    
    if (photoImage) {
		actionCount++;
		NSData *data = UIImageJPEGRepresentation(photoImage, 1.0);
		NSString *filename = @"tweet.jpg";
		if (!data) {
			data = UIImagePNGRepresentation(photoImage);
			filename = @"tweet.png";
		}
        [photoManager uploadImage:data
                         filename:filename
                        withWidth:photoImage.size.width 
                        andHeight:photoImage.size.height
                       andMessage:tweetTextView.text
                   andOrientation:photoImage.imageOrientation
                         andVenue:nil];
		
		
		[NSThread detachNewThreadSelector:@selector(uploadToTweetPhoto) toTarget:self withObject:nil];
		
    } else {
		[self submitToTwitter:nil];
		
		//post to facebook with google maps image rather than user supplied image
		if (isFacebookOn) {
			GraphAPI *graph = [[FacebookProxy instance] newGraph];
			[graph putWallPost:@"me" message:tweetTextView.text attachment:nil];
			[graph release];
		}
	}
}

- (void) uploadToTweetPhoto {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.tweetPhoto = [[TweetPhoto alloc] initWithSetup:[[FoursquareAPI sharedInstance] userName] identitySecret:[[FoursquareAPI sharedInstance] passWord] apiKey:@"bd1cf27c-0f19-4af5-b409-1c1a5bd35332" serviceName:@"Foursquare" isoAuth:NO];
	tweetPhotoResponse = [[self.tweetPhoto photoUpload:UIImageJPEGRepresentation(photoImage, 1.0) comment:tweetTextView.text tags:@"Kickball" latitude:[[KBLocationManager locationManager] latitude] longitude:[[KBLocationManager locationManager] longitude]] retain];
	[pool release];
	DLog(@"tweetphoto url: %@", tweetPhotoResponse.mediaUrl);
	[self performSelectorOnMainThread:@selector(submitToTwitter:) withObject:tweetPhotoResponse waitUntilDone:NO];
}

- (void) submitToTwitter:(TweetPhotoResponse*)response {
	DLog(@"tweetphoto response: %@", response);
	NSString *textToTweet = [NSString stringWithFormat:@"%@ %@", tweetTextView.text, response ? response.mediaUrl : @""];
	if (replyToStatusId && replyToStatusId > 0) {
		if (isGeotagOn) {
			[twitterEngine sendUpdate:textToTweet withLatitude:[[KBLocationManager locationManager] latitude] withLongitude:[[KBLocationManager locationManager] longitude] inReplyTo:[replyToStatusId longLongValue]];
		} else {
			[twitterEngine sendUpdate:textToTweet inReplyTo:[replyToStatusId longLongValue]];
		}
	} else {
		if (isGeotagOn) {
			[twitterEngine sendUpdate:textToTweet withLatitude:[[KBLocationManager locationManager] latitude] withLongitude:[[KBLocationManager locationManager] longitude]];
		} else {
			[twitterEngine sendUpdate:textToTweet];
		}
	}
}

// twitter response
- (void)statusesReceived:(NSArray *)statuses {
    [self decrementActionCount];
}

// foursquare response
- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    [self decrementActionCount];
}

// facebook response
- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([request.method isEqualToString:@"facebook.status.set"]) {
        NSDictionary* info = result;
        DLog(@"facebook status updated: %@", info);
    }
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
	[self backOneView];
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

- (void) removePhoto {
	[photoImage release];
    photoImage = nil;
    addPhotoButton.hidden = NO;
    removePhotoButton.hidden = YES;
    thumbnailBackground.hidden = YES;
    thumbnailPreview.image = nil;
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (void) textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 140) {
        textView.text = [textView.text substringToIndex:139];
    }
    characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [textView.text length]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self submitTweet];
		return NO;
    }
    return YES;
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
    
    photoImage = [photoManager imageByScalingToSize:initialImage toSize:CGSizeMake(480.0, round(480.0/roundedFloat))];
    [photoImage retain];
    thumbnailPreview.clipsToBounds = YES;
    thumbnailPreview.image = photoImage;
    thumbnailBackground.hidden = NO;
    addPhotoButton.hidden = YES;
    removePhotoButton.hidden = NO;
    
    DLog(@"image picker info: %@", info);
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
    DLog(@"YAY! Image uploaded! *****************%@",[request responseString]);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
    [self displayPopupMessage:message];
    [message release];
    
//    CGRect frame = CGRectMake(300, 50, 25, 25);
//    TTImageView *thumbnail = [[[TTImageView alloc] initWithFrame:frame] autorelease];
//    thumbnail.backgroundColor = [UIColor clearColor];
    //NSString *uuid = [[((NSDictionary*)[request responseString]) objectForKey:@"gift"] objectForKey:@"uuid"];
	//NSString *urlPath = [NSString stringWithFormat:@"http://s3.amazonaws.com/kickball/photos/%@/thumb/%@.jpg", uuid, uuid];

//    thumbnail.urlPath = [NSString stringWithFormat:@"http://s3.amazonaws.com/kickball/photos/%@/thumb/%@.jpg", uuid, uuid];
//    //thumbnail.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
//    [self.view addSubview:thumbnail];
    
    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
    [FlurryAPI logEvent:@"Image Upload Completed"];
	
	//
	
	if (isFacebookOn) {
		//if facebook submissio is turned on and I'm logged in and permitted to facebook
		SBJSON *parser = [SBJSON new];
		DLog(@"city grid response: %@", [request responseString]);
		id dict = [parser objectWithString:[request responseString] error:NULL];
		[parser release];
		
		NSString *uuid = [[(NSDictionary*)dict objectForKey:@"gift"] objectForKey:@"uuid"];
		NSString *urlPath = [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/large/%@.jpg", uuid, uuid];
		NSDictionary *fbPicture = [NSDictionary dictionaryWithObjectsAndKeys:urlPath, @"picture",@" ",@"caption",nil];
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph putWallPost:@"me" message:tweetTextView.text attachment:fbPicture];
		[graph release];
	}
	
}

- (void) photoQueueFinished:(ASIHTTPRequest *) request {
    [self decrementActionCount];
    
    DLog(@"YAY! Image queue is complete!");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    //[self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    DLog(@"Uhoh, it did fail!");
	//post to facebook with google map instead of user supplied image
	
	if (isFacebookOn) {
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph putWallPost:@"me" message:tweetTextView.text attachment:nil];
		[graph release];
	}
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
//    [tweetTextView release];
//    [characterCountLabel release];
//    [sendTweet release];
//    [cancel release];
    
    [replyToStatusId release];
    [replyToScreenName release];
    [retweetStatusId release];
    [retweetToScreenName release];
    [retweetTweetText release];
	[directMentionToScreenname release];
	[tweetPhotoResponse release];
    
//    [foursquareButton release];
//    [facebookButton release];
//    [geotagButton release];
//    [addPhotoButton release];
    [photoImage release];
    //[photoManager release];
//    [thumbnailPreview release];
    [super dealloc];
}

@end
