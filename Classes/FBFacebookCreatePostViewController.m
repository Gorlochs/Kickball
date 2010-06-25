//
//  FBFacebookCreatePostViewController.m
//  Kickball
//
//  Created by scott bates on 6/21/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "FBFacebookCreatePostViewController.h"
#import "KBAccountManager.h"
#import "FoursquareAPI.h"
#import "KBTwitterManager.h"
#import	"FacebookProxy.h"
#import "GraphAPI.h"
#import "SBJSON.h"
#import "KBLocationManager.h"
#import "KBFacebookListViewController.h"

@implementation FBFacebookCreatePostViewController
@synthesize delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	hideHeader = NO;
	pageViewType = KBPageViewTypeOther;
	pageType = KBPageTypeOther;
    [super viewDidLoad];
	
	[tweetTextView becomeFirstResponder];
    tweetTextView.font = [UIFont fontWithName:@"Helvetica" size:13.0];
	characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [tweetTextView.text length]];
	photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
	photoImage = nil;
	isFoursquareOn = ![[KBAccountManager sharedInstance] defaultPostToFoursquare];
	if ([[KBAccountManager sharedInstance] usesFoursquare]) {
		[self toggleFoursquare];
	}else {
		isFoursquareOn = NO;
		foursquareButton.enabled = NO;
	}
	
	isTwitterOn = ![[KBAccountManager sharedInstance] defaultPostToTwitter];
	if ([[KBAccountManager sharedInstance] usesTwitter]) {
		[self toggleTwitter];
	}else {
		isTwitterOn = NO;
		twitterButton.enabled = NO;
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#pragma mark -
#pragma mark IBAction methods

- (void) submitTweet {
    
	[tweetTextView resignFirstResponder];
    [self startProgressBar:@"Submitting..."];
    [self dismissModalViewControllerAnimated:YES];
    actionCount = 1;
	//[NSThread detachNewThreadSelector:@selector(threadedSubmit) toTarget:self withObject:nil];
	[self threadedSubmit];

}

-(void)threadedSubmit{
    pool = [[NSAutoreleasePool alloc] init];
	actionCount = 1;
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
	if (isTwitterOn) {
		actionCount++;
		if ([[KBAccountManager sharedInstance] usesGeoTag]) {
			[[KBTwitterManager twitterManager] setDelegate:self];
			[[[KBTwitterManager twitterManager] twitterEngine] sendUpdate:tweetTextView.text withLatitude:[[KBLocationManager locationManager] latitude] withLongitude:[[KBLocationManager locationManager] longitude]];
		} else {
			[[KBTwitterManager twitterManager] setDelegate:self];
			[[[KBTwitterManager twitterManager] twitterEngine] sendUpdate:tweetTextView.text];
		}
	}
	
    
    if (photoImage) {
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
    }else{
		//post to facebook with google maps image rather than user supplied image
		GraphAPI *graph = [[FacebookProxy instance] newGraph];
		[graph putWallPost:@"me" message:tweetTextView.text attachment:nil];
		[graph release];
		//[self decrementActionCount];
		//[self closeUpShop];
		[self decrementActionCount];
		
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

- (void) toggleTwitter {
    if (isTwitterOn) {
        [twitterButton setImage:[UIImage imageNamed:@"sendTW02.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"sendTW01.png"] forState:UIControlStateHighlighted];
    } else {
        [twitterButton setImage:[UIImage imageNamed:@"sendTW01.png"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"sendTW02.png"] forState:UIControlStateHighlighted];
    }
    isTwitterOn = !isTwitterOn;
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
	
	SBJSON *parser = [[SBJSON new] autorelease];
	id dict = [parser objectWithString:[request responseString] error:NULL];
	
	NSString *uuid = [[(NSDictionary*)dict objectForKey:@"gift"] objectForKey:@"uuid"];
	NSString *urlPath = [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/large/%@.jpg", uuid, uuid];
	NSDictionary *fbPicture = [NSDictionary dictionaryWithObjectsAndKeys:urlPath, @"picture",@" ",@"caption",nil];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	[graph putWallPost:@"me" message:tweetTextView.text attachment:fbPicture];
	[graph release];
	//[self closeUpShop];
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
    [delegate displayPopupMessage:message];
    [message release];
    [FlurryAPI logEvent:@"Image Upload Completed- facebook post"];

	
}

- (void) photoQueueFinished:(ASIHTTPRequest *) request {
    
    DLog(@"YAY! Image queue is complete!");
	//[self performSelectorOnMainThread:@selector(closeUpShop) withObject:nil waitUntilDone:NO];
    [self decrementActionCount];

	
    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
    
    //[self retrievePhotos];
}

- (void) photoUploadFailed:(ASIHTTPRequest *) request {
    DLog(@"Uhoh, it did fail!");
	//post to facebook with google map instead of user supplied image
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	[graph putWallPost:@"me" message:tweetTextView.text attachment:nil];
	KBMessage *message = [[KBMessage alloc] initWithMember:@"Error" andMessage:@"Image upload failed!"];
    [delegate displayPopupMessage:message];
    [message release];
    [FlurryAPI logEvent:@"Image Upload Failed- facebook post"];
	[self decrementActionCount];

}


- (void) removePhoto {
	[photoImage release];
    photoImage = nil;
    addPhotoButton.hidden = NO;
    removePhotoButton.hidden = YES;
    thumbnailBackground.hidden = YES;
    thumbnailPreview.image = nil;
}


- (void) decrementActionCount {
    actionCount--;
    if (actionCount == 0) {
        [self closeUpShop];
    }
}

- (void) closeUpShop {
	[pool release];
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
	[self.navigationController popViewControllerAnimated:YES];
	[(KBFacebookListViewController*)delegate performSelectorOnMainThread:@selector(delayedRefresh) withObject:nil waitUntilDone:NO];
	//[delegate performSelector:@selector(refreshTable) withObject:nil afterDelay:3.0f];
}

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
	[photoImage release];
	[delegate release];
    [super dealloc];
}


@end
