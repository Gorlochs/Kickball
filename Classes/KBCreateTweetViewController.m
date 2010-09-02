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
#import "KBDialogueManager.h"


@implementation KBCreateTweetViewController

@synthesize replyToStatusId;
@synthesize replyToScreenName;
@synthesize retweetStatusId;
@synthesize retweetToScreenName;
@synthesize retweetTweetText;
@synthesize directMessageToScreenname;
@synthesize tweetPhoto;

- (void)viewDidLoad {
    hideHeader = NO;
	pageViewType = KBPageViewTypeOther;
	pageType = KBPageTypeOther;
	
    [super viewDidLoad];
	
    tweetTextView.text = [[KBPhotoManager sharedInstance] photoTextPlaceholder];
    
	// mini-hack to turn off the foursquare button. we might decide to keep it on by default
	//isFoursquareOn = YES; --commented out...  calling the toggle will actually turn it on. so this was actually turning it off.
	isFoursquareOn = [[KBAccountManager sharedInstance] twitterPollinatesFoursquare];
	if (![[KBAccountManager sharedInstance] usesFoursquare]) {
		isFoursquareOn = NO;
		foursquareButton.enabled = NO;
		foursquareButton.adjustsImageWhenDisabled = NO;
	}
	[self updateFoursquareButt];

	isFacebookOn = [[KBAccountManager sharedInstance] twitterPollinatesFacebook];
	if (![[KBAccountManager sharedInstance] usesFacebook]) {
		isFacebookOn = NO;
		facebookButton.enabled = NO;
		facebookButton.adjustsImageWhenDisabled = NO;

	}
	[self updateFacebookButt];

	//[self toggleFoursquare];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createTweetStatusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    if (self.retweetTweetText) {
        tweetTextView.text = [NSString stringWithFormat:@"RT @%@ %@", self.replyToScreenName, self.retweetTweetText];
    } else if (self.replyToScreenName) {
        tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.replyToScreenName];
    } else if (self.directMessageToScreenname) {
		//tweetTextView.text = [NSString stringWithFormat:@"D @%@ ", self.directMessageToScreenname];
		foursquareButton.enabled = NO;
		facebookButton.enabled = NO;
		isFacebookOn = NO;
		isFoursquareOn = NO;
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

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	DLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
	[self stopProgressBar];
}

#pragma mark -
#pragma mark IBAction methods

- (void) submitTweet {
    
	if ([tweetTextView.text length] > 140) {
		KBMessage *theMessage = [[KBMessage alloc] initWithMember:@"Form Error"	andMessage:@"Oops, keep your tweets under 140 characters please!"];
		[[KBDialogueManager sharedInstance] displayMessage:theMessage];
		[theMessage release];
	} else if (tweetTextView.text && ![tweetTextView.text isEqualToString:@""]) {
		[tweetTextView resignFirstResponder];
		sendTweet.enabled = NO;
		[self startProgressBar:@"Submitting..."];
		[self dismissModalViewControllerAnimated:YES];
		actionCount = 1;

		twitterManager.delegate = self;
		photoManager.delegate = self;
		
		/* this is double posting to facebook.   wait and post with the image
		if (isFacebookOn && [[KBAccountManager sharedInstance] usesFacebook]) {
			actionCount++;
			DLog(@"facebook  is on and the status will be updated (hopefully)");
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:tweetTextView.text, @"status", nil];
			[[FBRequest requestWithDelegate:self] call:@"facebook.status.set" params:params dataParam:nil];
		}
		 */
		
		if (isFacebookOn) {
			actionCount++;
		}
		
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
			if(![[FoursquareAPI sharedInstance] isAuthenticated]){
				KBMessage *message = [[KBMessage alloc] initWithMember:@"Error" andMessage:@"Please sign in to Foursquare before submitting an image."];
				[self displayPopupMessage:message];
				[message release];
				return;
			}

			actionCount++;
			NSData *data = UIImageJPEGRepresentation(photoImage, 1.0);
			NSString *filename = @"tweet.jpg";
			if (!data) { // i'm pretty sure this doesn't work
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
			if (isFacebookOn) {
				[NSThread detachNewThreadSelector:@selector(uploadToFacebook) toTarget:self withObject:nil];
			}
		} else {
			[self submitToTwitter:nil];
			if (isFacebookOn) {
				//[Utilities putGoogleMapsWallPostWithMessage:tweetTextView.text andVenue:nil andLink:nil];
				GraphAPI *graph = [[FacebookProxy instance] newGraph];
				[graph simpleStatusPost:tweetTextView.text];	
				[graph release];		
			}
		}
	} else {
		[tweetTextView resignFirstResponder];
		
		KBMessage *theMessage = [[KBMessage alloc] initWithMember:@"Form Error"	andMessage:@"Oops, better fill in the tweet before hitting submit."];
		[[KBDialogueManager sharedInstance] displayMessage:theMessage];
		[theMessage release];
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

-(void) uploadToFacebook{
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	[graph postToWall:tweetTextView.text withImage:photoImage];	
	[graph release];
}

- (void) submitToTwitter:(TweetPhotoResponse*)response {
	DLog(@"tweetphoto response: %@", response);
	NSString *textToTweet = [NSString stringWithFormat:@"%@ %@", tweetTextView.text, response ? response.mediaUrl : @""];
	if (directMessageToScreenname) {
		[twitterEngine sendDirectMessage:textToTweet to:directMessageToScreenname];
	} else if (replyToStatusId && replyToStatusId > 0) {
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
	DLog(@"create tweet status: %@", statuses);
    [self decrementActionCount];
}

- (void)directMessagesReceived:(NSArray *)messages {
	DLog(@"create DM messages: %@", messages);
    [self decrementActionCount];
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {
    DLog(@"requestSucceeded: %@", connectionIdentifier);
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
	@synchronized(self) {
		actionCount--;
		NSLog(@"^v^v^v^v^v^v^ decrementing action count %d ^v^v^v^v^v^v^", actionCount);
		if (actionCount == 0) {
			[self closeUpShop];
		}
	}
}

- (void) closeUpShop {
    [self stopProgressBar];
	
	KBMessage *message = [[KBMessage alloc] initWithMember:@"Twitter Message" andMessage:@"Your tweet has been sent!"];
	[[KBDialogueManager sharedInstance] displayMessage:message];
	[message release];
	[self backOneView];
}

- (void) toggleFoursquare {
    isFoursquareOn = !isFoursquareOn;
	[self updateFoursquareButt];
	[[KBAccountManager sharedInstance] setTwitterPollinatesFoursquare:isFoursquareOn];

}

-(void) updateFoursquareButt{
	if (isFoursquareOn) {
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ01.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ02.png"] forState:UIControlStateHighlighted];
    } else {
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ02.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"send4SQ01.png"] forState:UIControlStateHighlighted];
    }
}

- (void) toggleFacebook {
    isFacebookOn = !isFacebookOn;
	[self updateFacebookButt];
	[[KBAccountManager sharedInstance] setTwitterPollinatesFacebook:isFacebookOn];
	[[KBAccountManager sharedInstance] checkForCrossPollinateWarning:@"twitter"];

}
-(void) updateFacebookButt{
	if (isFacebookOn) {
        [facebookButton setImage:[UIImage imageNamed:@"sendFB01.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"sendFB02.png"] forState:UIControlStateHighlighted];
    } else {
        [facebookButton setImage:[UIImage imageNamed:@"sendFB02.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"sendFB01.png"] forState:UIControlStateHighlighted];
    }	
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
		characterCountLabel.textColor = [UIColor redColor];
//        textView.text = [textView.text substringToIndex:140];
    } else {
		characterCountLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
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
	thumbnailPreview.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailBackground.hidden = NO;
    addPhotoButton.hidden = YES;
    removePhotoButton.hidden = NO;
    
    DLog(@"image picker info: %@", info);
    
    tweetTextView.text = [[KBPhotoManager sharedInstance] photoTextPlaceholder];
    [[KBPhotoManager sharedInstance] setPhotoTextPlaceholder:@""];
}

- (void) getPhoto:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void) choosePhotoSelectMethod {
    [[KBPhotoManager sharedInstance] setPhotoTextPlaceholder:tweetTextView.text];
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
    DLog(@"YAY! Image uploaded! *****************%@",[request responseString]);
    [self decrementActionCount];
//    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Okay, your image is uploaded!"];
//    [self displayPopupMessage:message];
//    [message release];
    
    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
    [FlurryAPI logEvent:@"Image Upload Completed"];
}

- (void) photoQueueFinished:(ASIHTTPRequest *) request {
    [self decrementActionCount];
    
    DLog(@"YAY! Image queue is complete!");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    //[self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    DLog(@"Uhoh, it did fail!");
	if (isFacebookOn) {
        //[Utilities putGoogleMapsWallPostWithMessage:tweetTextView.text andVenue:nil andLink:nil];
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph simpleStatusPost:tweetTextView.text];	
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
	photoManager.delegate = nil;
	   
    [replyToStatusId release];
    [replyToScreenName release];
    [retweetStatusId release];
    [retweetToScreenName release];
    [retweetTweetText release];
	[directMessageToScreenname release];
	[tweetPhotoResponse release];
    [tweetPhoto release];
    if (photoImage) [photoImage release];
    [super dealloc];
}

@end
