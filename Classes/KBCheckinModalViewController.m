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

@implementation KBCheckinModalViewController

@synthesize venue;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    hideHeader = YES;
    hideFooter = YES;
    
	//twitterManager = [KBTwitterManager twitterManager];
	//twitterManager.delegate = self;
    //self.twitterEngine = [twitterManager twitterEngine];
    [[KBTwitterManager twitterManager] setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusRetrieved:) name:kTwitterStatusRetrievedNotificationKey object:nil];
    
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    
    photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
    
    FSUser* user = [self getAuthenticatedUser];
    DLog(@"user: %@", user);
//    facebookButton.enabled = user.facebook != nil;
//    twitterButton.enabled = user.twitter != nil;
	
	
	DLog("auth'd user: %@", [self getAuthenticatedUser]);
    // hack
	
	isFoursquareOn = YES;
	isTwitterOn = ![[KBAccountManager sharedInstance] defaultPostToTwitter];
	if ([[KBAccountManager sharedInstance] usesTwitter]) {
		[self toggleTwitter];
	}else {
		isTwitterOn = NO;
		twitterButton.enabled = NO;
	}
	isFacebookOn = ![[KBAccountManager sharedInstance] defaultPostToFacebook];
	if ([[KBAccountManager sharedInstance] usesFacebook]) {
		[self toggleFacebook];
	}else {
		isFacebookOn = NO;
		facebookButton.enabled = NO;
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

- (NSString*)formatCheckinMessage:(NSString*)shout {
	if (![shout isEqualToString:@""]) {
		return [NSString stringWithFormat:@"%@ (just checked into %@) %@", shout, venue.name, [Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]];
	}
	return [NSString stringWithFormat:@"I just checked into %@. %@", venue.name, [Utilities getShortenedUrlFromFoursquareVenueId:venue.venueid]];
}

- (void) checkin {
    [checkinTextField resignFirstResponder];
    [self startProgressBar:@"Checking in..."];
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
    } else {
		if (isFacebookOn ) {
            //post to facebook with google maps image rather than user supplied image
            NSMutableString *addy = [[NSMutableString alloc] initWithString:venue.venueAddress];
            [addy replaceOccurrencesOfString:@" " withString:@"+" options:NSLiteralSearch range:NSMakeRange(0, [addy length])];
            NSMutableString *urlPath = [[NSMutableString alloc] initWithString:@"http://maps.google.com/maps/api/staticmap?size=96x96&markers=icon:http://chart.apis.google.com/chart%3Fchst%3Dd_map_pin_icon%26chld%3Dcafe%257C996600|"];
            [urlPath appendFormat:@"%@&sensor=true", addy];
            NSDictionary *googleMapPic = [NSDictionary dictionaryWithObjectsAndKeys:urlPath, @"picture",@" ",@"caption",nil];
            GraphAPI *graph = [[FacebookProxy instance] newGraph];
            [graph putWallPost:@"me" message:[self formatCheckinMessage:checkinTextField.text] attachment:googleMapPic];
            [graph release];
            [addy release];
            [urlPath release];
		}
		
	    if (isTwitterOn) {
			[self submitToTwitter:nil];
		}
	}
    
    [FlurryAPI logEvent:@"checked in"];
}

- (void) uploadToTweetPhoto {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	tweetPhoto = [[TweetPhoto alloc] initWithSetup:[[FoursquareAPI sharedInstance] userName] identitySecret:[[FoursquareAPI sharedInstance] passWord] apiKey:@"bd1cf27c-0f19-4af5-b409-1c1a5bd35332" serviceName:@"Foursquare" isoAuth:NO];
	tweetPhotoResponse = [[tweetPhoto photoUpload:UIImageJPEGRepresentation(photoImage, 1.0) comment:checkinTextField.text tags:@"Kickball" latitude:[[KBLocationManager locationManager] latitude] longitude:[[KBLocationManager locationManager] longitude]] retain];
	[pool release];
	DLog(@"tweetphoto url: %@", tweetPhotoResponse.mediaUrl);
	[self performSelectorOnMainThread:@selector(submitToTwitter:) withObject:tweetPhotoResponse waitUntilDone:NO];
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
}

- (void) decrementActionCount {
    actionCount--;
	DLog(@"action count has been decremented: %d", actionCount);
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
	
	if (isFacebookOn) {
		//if facebook submissio is turned on and I'm logged in and permitted to facebook
		SBJSON *parser = [SBJSON new];
		id dict = [parser objectWithString:[request responseString] error:NULL];
		[parser release];
		
		NSString *uuid = [[(NSDictionary*)dict objectForKey:@"gift"] objectForKey:@"uuid"];
		NSString *urlPath = [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/large/%@.jpg", uuid, uuid];
		NSDictionary *fbPicture = [NSDictionary dictionaryWithObjectsAndKeys:urlPath, @"picture",@" ",@"caption",nil];
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph putWallPost:@"me" message:[self formatCheckinMessage:checkinTextField.text] attachment:fbPicture];
		[graph release];
		
	}
	
	
    //[self stopProgressBar];
    DLog(@"YAY! Image uploaded!");
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
    //[twitterEngine release];
    [photoManager release];
    [thumbnailPreview release];
    [super dealloc];
}

@end
