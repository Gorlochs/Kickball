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
#import "FacebookProxy.h"
#import "GraphAPI.h"
#import "SBJSON.h"
#import "OAToken.h"

@implementation KBCheckinModalViewController

@synthesize venue, parentController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    hideHeader = YES;
    hideFooter = YES;
    
	//twitterManager = [KBTwitterManager twitterManager];
	//twitterManager.delegate = self;
    //self.twitterEngine = [twitterManager twitterEngine];
    [[KBTwitterManager twitterManager] setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(limitTextField:) name:UITextFieldTextDidChangeNotification object:checkinTextField];

    
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    theTableView.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.0];
	self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.0];
    checkinTextField.text = [[KBPhotoManager sharedInstance] photoTextPlaceholder];
    
    photoManager = [KBPhotoManager sharedInstance]; 
    photoManager.delegate = self;
    
    FSUser* user = [self getAuthenticatedUser];
    DLog(@"user: %@", user);
//    facebookButton.enabled = user.facebook != nil;
//    twitterButton.enabled = user.twitter != nil;
	
	
	DLog("auth'd user: %@", [self getAuthenticatedUser]);
    // hack
	
	isFoursquareOn = YES;
	[self updateFoursquareButton];
	isTwitterOn = [[KBAccountManager sharedInstance] foursquarePollinatesTwitter];
	if (![[KBAccountManager sharedInstance] usesTwitter]) {
		isTwitterOn = NO;
		twitterButton.enabled = NO;
	}
	[self updateTwitterButton];
	isFacebookOn = [[KBAccountManager sharedInstance] foursquarePollinatesFacebook];
	if (![[KBAccountManager sharedInstance] usesFacebook]) {
		isFacebookOn = NO;
		facebookButton.enabled = NO;
	}
	[self updateFacebookButton];
    actionCount = 0;
}

- (void) cancelView {
    //[self dismissModalViewControllerAnimated:YES];
	[parentController closeCheckinView];
}

#pragma mark -
#pragma mark IBActions

- (void) toggleTwitter {
    isTwitterOn = !isTwitterOn;
	[self updateTwitterButton];
	[[KBAccountManager sharedInstance] setFoursquarePollinatesTwitter:isTwitterOn];
	[[KBAccountManager sharedInstance] checkForCrossPollinateWarning:@"foursquare"];

}
-(void)updateTwitterButton{
	if (isTwitterOn) {
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT01.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT02.png"] forState:UIControlStateHighlighted];
    } else {
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT02.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"checkinTWT01.png"] forState:UIControlStateHighlighted];
    }
}

- (void) toggleFacebook {
    isFacebookOn = !isFacebookOn;
	[self updateFacebookButton];
	[[KBAccountManager sharedInstance] setFoursquarePollinatesFacebook:isFacebookOn];
	[[KBAccountManager sharedInstance] checkForCrossPollinateWarning:@"foursquare"];

}
-(void)updateFacebookButton{
	if (isFacebookOn) {
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB01.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB02.png"] forState:UIControlStateHighlighted];
    } else {
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB02.png"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"checkinFB01.png"] forState:UIControlStateHighlighted];
    }
}

- (void) toggleFoursquare {
    isFoursquareOn = !isFoursquareOn;
	[self updateFoursquareButton];
}
-(void)updateFoursquareButton{
	if (isFoursquareOn) {
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ01.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ02.png"] forState:UIControlStateHighlighted];
    } else {
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ02.png"] forState:UIControlStateNormal];
        [foursquareButton setImage:[UIImage imageNamed:@"checkin4SQ01.png"] forState:UIControlStateHighlighted];
    }
}

#pragma mark -
#pragma mark shout related methods

- (NSString*)formatCheckinMessage:(NSString*)shout {
	if (![shout isEqualToString:@""]) {
		return [NSString stringWithFormat:@"%@ (just checked into %@) %@", shout, venue.name, [Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]];
	}
	return [NSString stringWithFormat:@"I just checked into %@. %@", venue.name, [Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]];
}

- (void)delayedCheckin {
    actionCount = 1;
    
    [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:venue.venueid 
                                                  andShout:checkinTextField.text 
                                                   offGrid:!isFoursquareOn
                                                 toTwitter:NO
                                                toFacebook:NO 
                                                withTarget:self 
                                                 andAction:@selector(checkinResponseReceived:withResponseString:)];
    
    if (photoImage) {
		actionCount++;
		DLog(@"photo is on. action count has been incremented: %d", actionCount);
		self.hasPhoto = YES;
        [photoManager uploadImage:UIImageJPEGRepresentation(photoImage, 1.0) 
                         filename:@"tweet.jpg" 
                        withWidth:photoImage.size.width 
                        andHeight:photoImage.size.height
                       andMessage:checkinTextField.text
                   andOrientation:photoImage.imageOrientation
                         andVenue:venue];
		
	    if (isTwitterOn) {
			[NSThread detachNewThreadSelector:@selector(uploadToTweetPhoto) toTarget:self withObject:nil];
		}
		if (isFacebookOn){
			[NSThread detachNewThreadSelector:@selector(uploadToFacebook) toTarget:self withObject:nil];
		}
    } else {
		if (isFacebookOn ) {
            [Utilities putGoogleMapsWallPostWithMessage:[self formatCheckinMessage:checkinTextField.text] andVenue:venue andLink:[Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]];
		}
		
	    if (isTwitterOn) {
			[self submitToTwitter:nil];
		}
	}
    
    [FlurryAPI logEvent:@"checked in"];
}

- (void)checkin {
	checkinButton.enabled = NO;
	[checkinTextField resignFirstResponder];
    [self startProgressBar:@"Checking in..."];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(delayedCheckin) userInfo:nil repeats:NO];
}

- (void) uploadToTweetPhoto {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//old tweetPhoto using 4sq
	//tweetPhoto = [[TweetPhoto alloc] initWithSetup:[[FoursquareAPI sharedInstance] userName] identitySecret:[[FoursquareAPI sharedInstance] passWord] apiKey:@"bd1cf27c-0f19-4af5-b409-1c1a5bd35332" serviceName:@"Foursquare" isoAuth:NO];
	
	//new tweetPhoto using twitter oAuth
	tweetPhoto = [[TweetPhoto alloc] initWithSetup:[(OAToken*)[[[KBTwitterManager twitterManager] twitterEngine] accessToken] key] identitySecret:[(OAToken*)[[[KBTwitterManager twitterManager] twitterEngine] accessToken] secret] apiKey:@"bd1cf27c-0f19-4af5-b409-1c1a5bd35332" serviceName:@"Twitter" isoAuth:YES];
	
	NSString *tweetPhotoComment = nil;
	if ([checkinTextField.text length] > 0 && [checkinTextField.text length] < 120) {
		tweetPhotoComment = checkinTextField.text;
	} else if ([checkinTextField.text length] > 120) {
		tweetPhotoComment = [NSString stringWithFormat:@"%@...",[checkinTextField.text substringToIndex:120]];
	} else {
		tweetPhotoComment = [NSString stringWithFormat:@"Photo at %@", venue.name];
	}

	[tweetPhotoResponse release];
	tweetPhotoResponse = nil;
	tweetPhotoResponse = [[tweetPhoto photoUpload:UIImageJPEGRepresentation(photoImage, 1.0) comment:tweetPhotoComment tags:@"Kickball" latitude:[[KBLocationManager locationManager] latitude] longitude:[[KBLocationManager locationManager] longitude]] retain];
	[pool release];
	DLog(@"tweetphoto url: %@", tweetPhotoResponse.mediaUrl);
	[self performSelectorOnMainThread:@selector(submitToTwitter:) withObject:tweetPhotoResponse waitUntilDone:NO];
}

-(void) uploadToFacebook{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	[graph postToWall:[self formatCheckinMessage:checkinTextField.text] withImage:photoImage];	
	[graph release];
	[pool release];
}

- (void) submitToTwitter:(TweetPhotoResponse*)response {
	actionCount++;
	DLog(@"twitter is on. action count has been incremented: %d", actionCount);
	DLog(@"tweetphoto response: %@", response);
	
	[[[KBTwitterManager twitterManager] twitterEngine] sendUpdate:[NSString stringWithFormat:@"%@ %@", [self formatCheckinMessage:checkinTextField.text], response ? response.mediaUrl : @""]
													 withLatitude:[[KBLocationManager locationManager] latitude] 
													withLongitude:[[KBLocationManager locationManager] longitude]];
}

// Twitter response
- (void)statusesReceived:(NSArray *)statuses {
    [self decrementActionCount];
}

// Facebook response
- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([request.method isEqualToString:@"facebook.status.set"]) {
        NSDictionary* info = result;
        DLog(@"facebook status updated: %@", info);
    }
    [self decrementActionCount];
}

// 4sq response
- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"instring: %@", inString);
//	NSArray *checkins = [FoursquareAPI checkinsFromResponseXML:inString];
//    if ([checkins count] > 0) {
//        checkin = [checkins objectAtIndex:0];
//        DLog(@"checkin: %@", checkin);
//    }
    checkin = [[FoursquareAPI checkinFromResponseXML:inString] retain];
    
    self.shoutToPush = [NSString stringWithString:checkinTextField.text];
	self.venueToPush = checkin.venue;
    if ([self getAuthenticatedUser].isPingOn && isFoursquareOn) {
        [self sendPushNotification];
    }
    
    [self decrementActionCount];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"didCheckin" object:nil]; 	
}

- (void) decrementActionCount {
    actionCount--;
	DLog(@"action count has been decremented: %d", actionCount);
    if (actionCount == 0) {
        [self closeUpShop];
    }
}

- (void) closeUpShop {
    NSDictionary *userInfo = nil;
    NSArray *checkinArray = [NSArray arrayWithObjects:checkin, nil];
    if ([checkinArray count] > 0) userInfo = [NSDictionary dictionaryWithObjects:checkinArray 
                                                         forKeys:[NSArray arrayWithObjects:@"checkin", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkedIn" object:self userInfo:userInfo];
    [self stopProgressBar];
    [self cancelView];
}

// NOTE: I'm not sure what this is doing, since there is no uitextview on this page 
#pragma mark 
#pragma mark UITextViewDelegate methods

- (void) textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 140) {
        textView.text = [textView.text substringToIndex:140];
    }
    characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [textView.text length]];
}

#pragma mark 
#pragma mark UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[self checkin];
	return YES;
}

#pragma mark
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (thumbnailPreview.image) {
		if (buttonIndex == 1) {
			[FlurryAPI logEvent:@"Choose Photo: Library"];
			[self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
		} else if (buttonIndex == 2) {
			[FlurryAPI logEvent:@"Choose Photo: New"];
			[self getPhoto:UIImagePickerControllerSourceTypeCamera];
		} else if (buttonIndex == actionSheet.destructiveButtonIndex) {
			thumbnailPreview.image = nil;
			photoImage = nil;
		}
	} else {
		if (buttonIndex == 0) {
			[FlurryAPI logEvent:@"Choose Photo: Library"];
			[self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
		} else if (buttonIndex == 1) {
			[FlurryAPI logEvent:@"Choose Photo: New"];
			[self getPhoto:UIImagePickerControllerSourceTypeCamera];
		}
	}
}

#pragma mark -
#pragma mark photo related methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:NO];
    
    DLog(@"image picker info: %@", info);
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
	
    thumbnailPreview.clipsToBounds = YES;
	thumbnailPreview.layer.masksToBounds = YES;
	thumbnailPreview.layer.cornerRadius = 4.0;
    thumbnailPreview.image = photoImage;
    
    checkinTextField.text = [[KBPhotoManager sharedInstance] photoTextPlaceholder];
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
    [[KBPhotoManager sharedInstance] setPhotoTextPlaceholder:checkinTextField.text];
	UIActionSheet *actionSheet = nil;
	if (thumbnailPreview.image) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"How would you like to select a photo?"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:@"Delete Photo"
										 otherButtonTitles:/*@"Photo Album", @"Take New Photo",*/ nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"How would you like to select a photo?"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Photo Album", @"Take New Photo", nil];
	}

    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void) photoUploadFinished:(ASIHTTPRequest *) request {
	/*
	if (isFacebookOn) {
		//if facebook submission is turned on and I'm logged in and permitted to facebook
		SBJSON *parser = [SBJSON new];
		id dict = [parser objectWithString:[request responseString] error:NULL];
		[parser release];
		
		NSString *uuid = [[(NSDictionary*)dict objectForKey:@"gift"] objectForKey:@"uuid"];
		NSString *urlPath = [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/large/%@.jpg", uuid, uuid];
		NSDictionary *fbPicture = [NSDictionary dictionaryWithObjectsAndKeys:urlPath, @"picture",@" ",@"caption",nil];
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph postToWall:[self formatCheckinMessage:checkinTextField.text] withImage:photoImage];
		//[graph putWallPost:@"me" message:[self formatCheckinMessage:checkinTextField.text] attachment:fbPicture];
		
		[graph release];
		
		//[[KBPhotoManager sharedInstance] uploadFacebookPhoto:UIImageJPEGRepresentation(photoImage, 1.0) withCaption:checkinTextField.text];
	}*/
	
    DLog(@"YAY! Image uploaded!");

//    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Okay, your image is uploaded!"];
//    [self displayPopupMessage:message];
//    [message release];
    
    //    CGRect frame = CGRectMake(300, 50, 25, 25);
    //    TTImageView *thumbnail = [[[TTImageView alloc] initWithFrame:frame] autorelease];
    //    thumbnail.backgroundColor = [UIColor clearColor];
    //    NSString *uuid = [[((NSDictionary*)[request responseString]) objectForKey:@"gift"] objectForKey:@"uuid"];
    //    thumbnail.urlPath = [NSString stringWithFormat:@"http://s3.amazonaws.com/kickball/photos/%@/thumb/%@.jpg", uuid, uuid];
    //    //thumbnail.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    //    [self.view addSubview:thumbnail];
    
    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
    [FlurryAPI logEvent:@"Image Upload Completed"];
	
    [self decrementActionCount];
}

- (void) photoQueueFinished:(ASIHTTPRequest *) request {
    //[self decrementActionCount];
    
    DLog(@"YAY! Image queue is complete!");
    
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    //[self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    [self stopProgressBar];
    [self decrementActionCount];
    DLog(@"Uhoh, it did fail!");
	if (isFacebookOn ) {
		//actionCount++;
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph putWallPost:@"me" message:[self formatCheckinMessage:checkinTextField.text] attachment:nil];
		[graph release];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

-(void) limitTextField:(NSNotification*)notification {
    if ([checkinTextField.text length] > 255) {
        checkinTextField.text = [checkinTextField.text substringToIndex:255];
    }
    characterCountLabel.text = [NSString stringWithFormat:@"%d/255", [checkinTextField.text length]];
}

#pragma mark 
#pragma mark memory management methods

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	twitterManager.delegate = nil;
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {} //satisfy MGTWitterEngineDelegate protocol requirements

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {}

- (void)dealloc {
	[parentController release];
	photoManager.delegate = nil;
    [venue release];
    [characterCountLabel release];
    [twitterButton release];
    [facebookButton release];
    [foursquareButton release];
    [checkinButton release];
    [checkinTextField release];
    [photoManager release];
    [thumbnailPreview release];
	[photoImage release];
	[tweetPhoto release];
	[tweetPhotoResponse release];
	//[checkin release];
    [super dealloc];
}

@end
