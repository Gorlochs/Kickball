// Copyright (c) 2009 Imageshack Corp.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "TwitEditorController.h"
#import "LoginController.h"
#import "MGTwitterEngine.h"
#import "TweetterAppDelegate.h"
#import "LocationManager.h"
#include "util.h"
#import "TweetQueue.h"
#import "TweetPlayer.h"
#import "ImageViewController.h"
#import "MGTwitterEngineFactory.h"
#import "AccountManager.h"
#import "Logger.h"

#define DEBUG_VIDEO_UPLOAD              0
#if DEBUG_VIDEO_UPLOAD
#   define DEBUG_VIDEO_FILE_NAME        @"test"
#   define DEBUG_VIDEO_FILE_EXT         @"mov"
#endif

#define DEBUG_IMAGE_UPLOAD				0
#if DEBUG_IMAGE_UPLOAD
#   define DEBUG_IMAGE_FILE_NAME        @"test"
#   define DEBUG_IMAGE_FILE_EXT         @"jpg"
#endif


#define SEND_SEGMENT_CNTRL_WIDTH			130
#define FIRST_SEND_SEGMENT_WIDTH			 66

#define IMAGES_SEGMENT_CONTROLLER_TAG		487
#define SEND_TWIT_SEGMENT_CONTROLLER_TAG	 42

#define PROGRESS_ACTION_SHEET_TAG										214
#define PHOTO_Q_SHEET_TAG												436
#define PROCESSING_PHOTO_SHEET_TAG										3

#define PHOTO_ENABLE_SERVICES_ALERT_TAG									666
#define PHOTO_DO_CANCEL_ALERT_TAG										13

#define K_UI_TYPE_MOVIE													@"public.movie"
#define K_UI_TYPE_IMAGE													@"public.image"

@implementation ImagePickerController

@synthesize twitEditor;

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:NO];
	//[twitEditor startUploadingOfPickedMediaIfNeed];
}

- (void)dealloc
{
	YFLog(@"Image picker - DEALLOC");
	[super dealloc];
}

@end

@implementation TwitEditorController

@synthesize progressSheet;
@synthesize currentMediaYFrogURL;
@synthesize connectionDelegate;
@synthesize _message;
@synthesize pickedVideo;
@synthesize pickedPhoto;
@synthesize previewImage;
@synthesize pickedPhotoData;
@synthesize location;

@synthesize pickImage;
@synthesize cancelButton;
@synthesize navItem;
@synthesize image;
@synthesize messageText;
@synthesize charsCount;
@synthesize progress;
@synthesize progressStatus;
@synthesize postImageSegmentedControl;
@synthesize imagesSegmentedControl;
@synthesize locationSegmentedControl;

- (void)setCharsCount
{
	charsCount.text = [NSString stringWithFormat:@"%d", MAX_SYMBOLS_COUNT_IN_TEXT_VIEW - [messageText.text length]];
}

- (void)setNavigatorButtons
{
	if(self.navigationItem.leftBarButtonItem != cancelButton)
	{
		[[self navigationItem] setLeftBarButtonItem:cancelButton animated:YES];
		if([self.navigationController.viewControllers count] == 1)
			cancelButton.title = NSLocalizedString(@"Clear", @"");
		else
			cancelButton.title = NSLocalizedString(@"Cancel", @"");
	}	
		
	if([self mediaIsPicked] || [[messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
	{
		if(self.navigationItem.rightBarButtonItem != segmentBarItem)
			self.navigationItem.rightBarButtonItem = segmentBarItem;
		
	}
	else
	{
		if(self.navigationItem.rightBarButtonItem)
			[[self navigationItem] setRightBarButtonItem:nil animated:YES];
	}
}

- (void)setMessageTextText:(NSString*)newText
{
	messageText.text = newText;
	[self setCharsCount];
	[self setNavigatorButtons];
}

- (NSRange)locationRange
{
	if (nil == self.location)
	{
		return NSMakeRange(0, 0);
	}
	
	return [messageText.text rangeOfString:self.location];
}

- (NSRange)urlPlaceHolderRange
{
	NSRange urlPlaceHolderRange = [messageText.text rangeOfString:photoURLPlaceholderMask];
	if(urlPlaceHolderRange.location == NSNotFound)
		urlPlaceHolderRange = [messageText.text rangeOfString:videoURLPlaceholderMask];
	return urlPlaceHolderRange;
}

- (NSString*)currentMediaURLPlaceholder
{
	if(pickedVideo)
		return videoURLPlaceholderMask;
	if(pickedPhoto)
		return photoURLPlaceholderMask;
	return nil;
}

- (void)setURLPlaceholder
{
	NSRange photoPlaceHolderRange = [messageText.text rangeOfString:photoURLPlaceholderMask];
	NSRange videoPlaceHolderRange = [messageText.text rangeOfString:videoURLPlaceholderMask];
	NSRange selectedRange = messageText.selectedRange;
	if(selectedRange.location == NSNotFound)
		selectedRange.location = messageText.text.length;

	if([self mediaIsPicked])
	{
		if(photoPlaceHolderRange.location == NSNotFound && pickedPhoto)
		{
			NSString *newText = messageText.text;
			if(videoPlaceHolderRange.location != NSNotFound)
			{
				if(selectedRange.location >= videoPlaceHolderRange.location && selectedRange.location < videoPlaceHolderRange.location + videoPlaceHolderRange.length)
				{
					selectedRange.location = videoPlaceHolderRange.location;
					selectedRange.length = 0;
				}
				newText = [newText stringByReplacingCharactersInRange:videoPlaceHolderRange withString:@""];
			}
			if(![newText hasSuffix:@"\n"])
				newText = [newText stringByAppendingString:@"\n"];
			[self setMessageTextText:[newText stringByAppendingString:photoURLPlaceholderMask]];
		}
		if(videoPlaceHolderRange.location == NSNotFound && pickedVideo)
		{
			NSString *newText = messageText.text;
			if(photoPlaceHolderRange.location != NSNotFound)
			{
				if(selectedRange.location >= photoPlaceHolderRange.location && selectedRange.location < photoPlaceHolderRange.location + photoPlaceHolderRange.length)
				{
					selectedRange.location = photoPlaceHolderRange.location;
					selectedRange.length = 0;
				}
				newText = [newText stringByReplacingCharactersInRange:photoPlaceHolderRange withString:@""];
			}
			if(![newText hasSuffix:@"\n"])
				newText = [newText stringByAppendingString:@"\n"];
			[self setMessageTextText:[newText stringByAppendingString:videoURLPlaceholderMask]];
		}
	}
	else
	{
		if(photoPlaceHolderRange.location != NSNotFound)
		{
			if(selectedRange.location >= photoPlaceHolderRange.location && selectedRange.location < photoPlaceHolderRange.location + photoPlaceHolderRange.length)
			{
				selectedRange.location = photoPlaceHolderRange.location;
				selectedRange.length = 0;
			}
			[self setMessageTextText:[messageText.text stringByReplacingCharactersInRange:photoPlaceHolderRange withString:@""]];
		}
		if(videoPlaceHolderRange.location != NSNotFound)
		{
			if(selectedRange.location >= videoPlaceHolderRange.location && selectedRange.location < videoPlaceHolderRange.location + videoPlaceHolderRange.length)
			{
				selectedRange.location = videoPlaceHolderRange.location;
				selectedRange.length = 0;
			}
			[self setMessageTextText:[messageText.text stringByReplacingCharactersInRange:videoPlaceHolderRange withString:@""]];
		}
	}
	messageText.selectedRange = selectedRange;
}

- (void)initData
{
	//_twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
    _twitter = [[MGTwitterEngineFactory createTwitterEngineForCurrentUser:self] retain];
    
    //YFLog(@"%@", [((SA_OAuthTwitterEngine*)_twitter).authorizeURL path]);
    //YFLog(@"%@", [((SA_OAuthTwitterEngine*)_twitter).accessTokenURL path]);
    //YFLog(@"%@", [((SA_OAuthTwitterEngine*)_twitter).requestTokenURL path]);
    
	inTextEditingMode = NO;
	suspendedOperation = noTEOperations;
	photoURLPlaceholderMask = [NSLocalizedString(@"YFrog image URL placeholder", @"") retain];
	videoURLPlaceholderMask = [NSLocalizedString(@"YFrog video URL placeholder", @"") retain];
	messageTextWillIgnoreNextViewAppearing = NO;
	twitWasChangedManually = NO;
	_queueIndex = -1;
    _canShowCamera = NO;
    [self progressClear];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setQueueTitle) name:@"QueueChanged" object:nil];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if(self) {
        [self initData];
    }
	return self;
}

- (id)init
{
	return [self initWithNibName:@"PostImage" bundle:nil];
}

- (id)initInCameraMode
{
    if ((self = [self init]))
    {
        _canShowCamera = YES;
    }
    return self;
}

-(void)dismissProgressSheetIfExist
{
	if(self.progressSheet)
	{
		[self.progressSheet dismissWithClickedButtonIndex:0 animated:YES];
		self.progressSheet = nil;
	}
}

- (void)dealloc 
{
    YFLog(@"tweetEditor - DEALLOC");
	while (_indicatorCount) 
		[self releaseActivityIndicator];
	[_twitter closeAllConnections];
	[_twitter removeDelegate];
	[_twitter release];
	[_indicator release];
	[defaultTintColor release];
	[segmentBarItem release];
	[photoURLPlaceholderMask release];
	[videoURLPlaceholderMask release];
	self.location = nil;
	self.currentMediaYFrogURL = nil;
	self.connectionDelegate = nil;
	self._message = nil;
	self.pickedPhoto = nil;
	self.pickedVideo = nil;
	self.previewImage = nil;
	self.pickedPhotoData = nil;
	[self dismissProgressSheetIfExist];
	
	[image release];
	image = nil;
    [pickImage release];
	pickImage = nil;
    [cancelButton release];
	cancelButton = nil;	
	[navItem release];
	navItem = nil;
	[messageText release];
	messageText = nil;
	[charsCount release];
	charsCount = nil;
    [progress release];
	progress = nil;
	[progressStatus release];
	progressStatus = nil;
	[postImageSegmentedControl release];
	postImageSegmentedControl = nil;
	[imagesSegmentedControl release];
	imagesSegmentedControl = nil;
	[locationSegmentedControl release];
	locationSegmentedControl = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)setQueueTitle
{
	int count = [[TweetQueue sharedQueue] count];
	NSString *title = nil;
	if(count)
		title = [NSString stringWithFormat:NSLocalizedString(@"QueueButtonTitleFormat", @""), count];
	else
		title = NSLocalizedString(@"EmptyQueueButtonTitleFormat", @"");
	if(![[postImageSegmentedControl titleForSegmentAtIndex:0] isEqualToString:title])
		[postImageSegmentedControl setTitle:title forSegmentAtIndex:0];
}

- (void)setImageImage:(UIImage*)newImage
{
	image.image = newImage;
	[self setURLPlaceholder];
	[self setNavigatorButtons];
}

- (void)setImage:(UIImage*)img movie:(NSURL*)url
{
	self.pickedPhoto = img;
	self.pickedVideo = url;
	
	if (!img)
	{
		self.previewImage = nil;
		self.pickedPhotoData = nil;		
	}
	
	if(url)
	{
		self.previewImage = [UIImage imageNamed:@"MovieIcon.tif"];
	}
	
	if (self.previewImage)
	{
		[self setImageImage:self.previewImage];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	messageTextWillIgnoreNextViewAppearing = YES;
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[messageText becomeFirstResponder];
	[self setNavigatorButtons];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishWithPickingPhoto:(UIImage *)img pickingMovie:(NSURL*)url
{    
    [self progressClear];
    
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	twitWasChangedManually = YES;
	messageTextWillIgnoreNextViewAppearing = YES;

	BOOL startNewUpload = NO;
	
	if(pickedPhoto != img || pickedVideo != url)
	{
		startNewUpload = YES;
		
		if(img)
		{
			BOOL needToResize = NO;
			BOOL needToRotate = NO;
			isImageNeedToConvert(img, &needToResize, &needToRotate);
			if (img.size.width > 500 || img.size.height > 500)
			{
				needToResize = YES;
			}
			
			if(needToResize || needToRotate)
			{
				self.progressSheet = ShowActionSheet(NSLocalizedString(@"Processing image...", @""), self, nil, self.view);
				self.progressSheet.tag = PROCESSING_PHOTO_SHEET_TAG;
			}
			
			[self setImage:img movie:nil];
			[self performSelector:@selector(updatePickedPhotoDataAndStartUpload) withObject:nil afterDelay:0.25];
		}
		else
		{
			[self setImage:nil movie:url];
			[self performSelectorOnMainThread:@selector(startUploadingOfPickedMediaIfNeed) withObject:nil waitUntilDone:NO];
		}
	}
	
	[self setNavigatorButtons];

	if(startNewUpload)
	{
		if(self.connectionDelegate)
			[self.connectionDelegate cancel];
		self.connectionDelegate = nil;
		self.currentMediaYFrogURL = nil;
	}

	[messageText becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
#if DEBUG_VIDEO_UPLOAD
    NSString *debugVideoFilePath = [[NSBundle mainBundle] pathForResource:DEBUG_VIDEO_FILE_NAME ofType:DEBUG_VIDEO_FILE_EXT];
    NSURL *theMovieURL = [NSURL fileURLWithPath:debugVideoFilePath];
    [self imagePickerController:picker didFinishWithPickingPhoto:nil pickingMovie:theMovieURL];
#elif DEBUG_IMAGE_UPLOAD
    NSString *debugImageFilePath = [[NSBundle mainBundle] pathForResource:DEBUG_IMAGE_FILE_NAME ofType:DEBUG_IMAGE_FILE_EXT];
    UIImage *theImage = [UIImage imageWithContentsOfFile:debugImageFilePath];
    [self imagePickerController:picker didFinishWithPickingPhoto:theImage pickingMovie:nil];
#else
	if([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:K_UI_TYPE_IMAGE])
		[self imagePickerController:picker didFinishWithPickingPhoto:[info objectForKey:@"UIImagePickerControllerOriginalImage"] pickingMovie:nil];
	else if([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:K_UI_TYPE_MOVIE])
		[self imagePickerController:picker didFinishWithPickingPhoto:nil pickingMovie:[info objectForKey:@"UIImagePickerControllerMediaURL"]];
#endif	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo 
{
	[self imagePickerController:picker didFinishWithPickingPhoto:img pickingMovie:nil];
}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
 
    [[NSNotificationCenter defaultCenter] removeObserver:self
                name:MPMoviePlayerPlaybackDidFinishNotification
                object:theMovie];
 
    // Release the movie instance created in playMovieAtURL:
    [theMovie release];
}

- (void)imageViewTouched:(NSNotification*)notification
{
	if(pickedPhoto)
	{
		UIViewController *imgViewCtrl = [[ImageViewController alloc] initWithImage:pickedPhoto];
		[self.navigationController pushViewController:imgViewCtrl animated:YES];
		[imgViewCtrl release];
	}
	else if(pickedVideo)
	{
		MPMoviePlayerController* theMovie = [[TweetPlayer alloc] initWithContentURL:pickedVideo];
		theMovie.scalingMode = MPMovieScalingModeAspectFill;
		theMovie.movieControlMode = MPMovieControlModeDefault;
 
		// Register for the playback finished notification.
		[[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(movieFinishedCallback:)
                name:MPMoviePlayerPlaybackDidFinishNotification
                object:theMovie];
 
		// Movie playback is asynchronous, so this method returns immediately.
		[theMovie play];
	}
}

- (void)appWillTerminate:(NSNotification*)notification
{
	if(![self mediaIsPicked] && ![[messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
		return;


	NSString *messageBody = messageText.text;
	if([self mediaIsPicked] && currentMediaYFrogURL)
	{
		messageBody = [messageBody stringByReplacingOccurrencesOfString:photoURLPlaceholderMask withString:currentMediaYFrogURL];
		messageBody = [messageBody stringByReplacingOccurrencesOfString:videoURLPlaceholderMask withString:currentMediaYFrogURL];
	}
    
    NSString *username = nil;
    if ([self isDirectMessage])
        if ([self respondsToSelector:@selector(username)])
            username = [self performSelector:@selector(username)];
    
	if(_queueIndex >= 0)
	{
		[[TweetQueue sharedQueue] replaceMessage: messageBody 
                                       withImageData: (pickedPhoto && !currentMediaYFrogURL) ? pickedPhotoData : nil  
                                       withMovie: (pickedVideo && !currentMediaYFrogURL) ? pickedVideo : nil
                                       inReplyTo: _queuedReplyId
                                         forUser: username
                                         atIndex:_queueIndex];
	}
	else
	{
		[[TweetQueue sharedQueue] addMessage: messageBody 
                                   withImageData: (pickedPhoto && !currentMediaYFrogURL) ? pickedPhotoData : nil  
                                   withMovie: (pickedVideo && !currentMediaYFrogURL) ? pickedVideo : nil
                                   inReplyTo: _message ? [[_message objectForKey:@"id"] intValue] : 0
                                     forUser: username];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad 
- (void)loadView
{
    //[super viewDidLoad];
    [super loadView];
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = NSLocalizedString(@"Back", @"");
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	[temporaryBarButtonItem release];
	
	self.navigationItem.title = NSLocalizedString(@"New Tweet", @"");
	messageText.delegate = self;
	
	postImageSegmentedControl.frame = CGRectMake(0, 0, SEND_SEGMENT_CNTRL_WIDTH, 30);
	segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:postImageSegmentedControl];
	[postImageSegmentedControl setWidth:FIRST_SEND_SEGMENT_WIDTH forSegmentAtIndex:0];
	defaultTintColor = [postImageSegmentedControl.tintColor retain];	// keep track of this for later
	
	[self setURLPlaceholder];
	
	BOOL cameraEnabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	BOOL libraryEnabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
	if(!cameraEnabled && !libraryEnabled)
		[pickImage setHidden:YES];

	[messageText becomeFirstResponder];
	inTextEditingMode = YES;
	
	_indicatorCount = 0;
	_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	CGRect frame = image.frame;
	CGRect indFrame = _indicator.frame;
	frame.origin.x = (int)((image.frame.size.width - indFrame.size.width) * 0.5f) + 1;
	frame.origin.y = (int)((image.frame.size.height - indFrame.size.height) * 0.5f) + 1;
	frame.size = indFrame.size;
	_indicator.frame = frame;
		
	[self setQueueTitle];
	[self setNavigatorButtons];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(imageViewTouched:) name:@"ImageViewTouched" object:image];
	[notificationCenter addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSRange urlPlaceHolderRange = [self urlPlaceHolderRange];
	if(urlPlaceHolderRange.location == NSNotFound && [self mediaIsPicked])
		return NO;
	
	if((urlPlaceHolderRange.location < range.location) && (urlPlaceHolderRange.location + urlPlaceHolderRange.length > range.location))
		return NO;		
	
	if(NSIntersectionRange(urlPlaceHolderRange, range).length > 0)
		return NO;
	
	NSRange locationRange = [self locationRange];
	if ((locationRange.location < range.location) && (locationRange.location + locationRange.length > range.location))
		return NO;
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
	twitWasChangedManually = YES;
	[self setCharsCount];
	[self setNavigatorButtons];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	inTextEditingMode = NO;
	[self setNavigatorButtons];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	inTextEditingMode = YES;
	[self setNavigatorButtons];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (IBAction)finishEditAction
{
	[messageText resignFirstResponder];
}

- (NSArray*)availableMediaTypes:(UIImagePickerControllerSourceType) pickerSourceType
{
	SEL selector = @selector(availableMediaTypesForSourceType:);
	NSMethodSignature *sig = [[UIImagePickerController class] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:[UIImagePickerController class]];
	[invocation setSelector:selector];
	[invocation setArgument:&pickerSourceType atIndex:2];
	[invocation invoke];
	NSArray *mediaTypes = nil;
	[invocation getReturnValue:&mediaTypes];
	return mediaTypes;
}

- (void)grabImage 
{
	BOOL imageAlreadyExists = [self mediaIsPicked];
	BOOL photoCameraEnabled = NO;
	BOOL photoLibraryEnabled = NO;
	BOOL movieCameraEnabled = NO;
	BOOL movieLibraryEnabled = NO;
    
	NSArray *mediaTypes = nil;

	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		photoLibraryEnabled = YES;
		if ([[UIImagePickerController class] respondsToSelector:@selector(availableMediaTypesForSourceType:)]) 
		{
			mediaTypes = [self availableMediaTypes:UIImagePickerControllerSourceTypePhotoLibrary];
			movieLibraryEnabled = [mediaTypes indexOfObject:K_UI_TYPE_MOVIE] != NSNotFound;
			photoLibraryEnabled = [mediaTypes indexOfObject:K_UI_TYPE_IMAGE] != NSNotFound;
		}

	}
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		photoCameraEnabled = YES;


		if ([[UIImagePickerController class] respondsToSelector:@selector(availableMediaTypesForSourceType:)]) 
		{
			mediaTypes = [self availableMediaTypes:UIImagePickerControllerSourceTypeCamera];
			movieCameraEnabled = [mediaTypes indexOfObject:K_UI_TYPE_MOVIE] != NSNotFound;
			photoCameraEnabled = [mediaTypes indexOfObject:K_UI_TYPE_IMAGE] != NSNotFound;
		}
	}

	NSString *buttons[5] = {0};
	int i = 0;
	
	if(photoCameraEnabled)
		buttons[i++] = NSLocalizedString(@"Use photo camera", @"");
	if(movieCameraEnabled)
		buttons[i++] = NSLocalizedString(@"Use video camera", @"");
	if(photoLibraryEnabled)
		buttons[i++] = NSLocalizedString(@"Use library", @"");
    //if(movieLibraryEnabled)
	//	buttons[i++] = NSLocalizedString(@"Use video library", @"");
	if(imageAlreadyExists)
		buttons[i++] = NSLocalizedString(@"RemoveImageTitle" , @"");
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil
													otherButtonTitles:buttons[0], buttons[1], buttons[2], buttons[3], buttons[4], nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	actionSheet.tag = PHOTO_Q_SHEET_TAG;
	[actionSheet showInView:self.view];
	[actionSheet release];
	
}

- (void)progressClear
{
    _dataSize = 0;
    [progressStatus setText:@""];
    [progress setProgress:0];
}

- (void)progressUpdate:(NSInteger)bytesWritten
{
    float delta = (float)bytesWritten / (float)_dataSize;
    
    [progress setProgress:delta];
    
    NSString *sizeText;
    NSString *suffix = @"bytes";
    
    float denominator = 1.0f;
    if (_dataSize / 1024 > 0)
    {
        denominator = 1024;
        if ((_dataSize % 1024) / 1024 > 0)
        {
            denominator += 1024;
            suffix = @"Mb";
        }
        else
            suffix = @"Kb";
    }
    
    
    sizeText = [NSString stringWithFormat:NSLocalizedString(@"%.1f of %.1f %@", @""), bytesWritten / denominator, _dataSize / denominator, suffix];
    [progressStatus setText:sizeText];
}

- (IBAction)attachImagesActions:(id)sender
{
	[self grabImage];
}

- (void)startUpload
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing startUpload of TwitEditController method...");
#endif	
	
	if (self.connectionDelegate)
	{
		self.connectionDelegate = nil;
	}
	
	if(![self mediaIsPicked])
		return;

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
#ifdef TRACE
	YFLog(@"	YFrog_DEBUG: Media is picked");
#endif
    
	// Image uploader will be released after finishing upload process by setting
	// self.connectionDelegate property to nil on uploadedImage: sender method
	ImageUploader *uploader = [[ImageUploader alloc] init];
	self.connectionDelegate = uploader;
	[self retainActivityIndicator];
	if(pickedPhoto && pickedPhotoData)
	{
		[uploader setImageDimension:imageDimension];
		[uploader postData:self.pickedPhotoData delegate:self userData:pickedPhoto];
	}
	else
    {
#ifdef TRACE
		YFLog(@"	YFrog_DEBUG: Picked video URL description: %@", [pickedVideo description]);
		YFLog(@"	YFrog_DEBUG: Picked video is file URL %d", (int)[pickedVideo isFileURL]);
#endif
		
        NSString *path;
        if ([pickedVideo isFileURL]) {
            path = [pickedVideo path];
        } else {
            path = [pickedVideo absoluteString];
        }
		
#ifdef TRACE
		YFLog(@"	YFrog_DEBUG: Path of the video file %@", path);
#endif		
		
        [uploader postMP4DataWithPath:path delegate:self userData:pickedVideo];
    }
	
	[uploader release];
}

- (void)convertPickedImageAndStartUpload
{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName: @"ClearCaches" object: nil];
	
	BOOL needToResize = NO;
	BOOL needToRotate = NO;
	int newDimension = isImageNeedToConvert(self.pickedPhoto, &needToResize, &needToRotate);
	if(needToResize || needToRotate)
	{
		UIImage *modifiedImage = imageScaledToSize(self.pickedPhoto, newDimension);
		if (nil != modifiedImage)
		{
			self.pickedPhoto = modifiedImage;
		}
	}
	
	[pool release];
	
	[self performSelector:@selector(updatePickedPhotoDataAndStartUpload) withObject:nil afterDelay:0.5];
}

- (void)updatePickedPhotoDataAndStartUpload
{
	BOOL isNeedToResize = NO;
	BOOL isNeedToRotate = NO;
	int newDimension = isImageNeedToConvert(self.pickedPhoto, &isNeedToResize, &isNeedToRotate);
	imageDimension = 0;
	if(isNeedToResize)
	{
		imageDimension = newDimension;
	}
	
	imageRotationAngle = 0;
	UIImageOrientation orient = self.pickedPhoto.imageOrientation;
	switch(orient) 
	{
		case UIImageOrientationUp:
			imageRotationAngle = 90;
			break;
			
		case UIImageOrientationDown:
			imageRotationAngle = 270;
			break;
			
		case UIImageOrientationLeft:
			imageRotationAngle = 180;
			break;
			
		case UIImageOrientationRight:
			imageRotationAngle = 0;
			break;
	}
	
	self.pickedPhotoData = UIImageJPEGRepresentation(self.pickedPhoto, 1.0f);

	[self performSelector:@selector(reducePickedPhotoSizeAndStartUpload) withObject:nil afterDelay:0.1];
}

- (void)reducePickedPhotoSizeAndStartUpload
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	UIImage *modifiedImage = imageScaledToSize(self.pickedPhoto, 480);
	if (nil != modifiedImage)
	{
		self.pickedPhoto = modifiedImage;
	}
	
	UIImage *thePreviewImage = imageScaledToSize(self.pickedPhoto, image.frame.size.width);
	self.previewImage = thePreviewImage;
	[self setImageImage:self.previewImage];	
	
	[pool release];
	
	[self performSelector:@selector(startUploadingOfPickedMediaIfNeed) withObject:nil afterDelay:0.1];
}

- (void)startUploadingOfPickedMediaIfNeed
{
	if(!self.currentMediaYFrogURL && [self mediaIsPicked] && !connectionDelegate)
		[self startUpload];
	
	if(self.progressSheet && self.progressSheet.tag == PROCESSING_PHOTO_SHEET_TAG)
	{
		[self.progressSheet dismissWithClickedButtonIndex:-1 animated:YES];
		self.progressSheet = nil;
	}		
}

- (void)postImageAction 
{
	if(![self mediaIsPicked] && ![[messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
		return;

	if([messageText.text length] > MAX_SYMBOLS_COUNT_IN_TEXT_VIEW)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You can not send message", @"") 
														message:NSLocalizedString(@"Cant to send too long message", @"")
													   delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
		[alert show];
		[alert release];
		return;
	}

	if(!self.currentMediaYFrogURL && [self mediaIsPicked] && !self.progressSheet)
	{
		suspendedOperation = send;
		if(!connectionDelegate)
			[self startUpload];
		self.progressSheet = ShowActionSheet(NSLocalizedString(@"Upload Image to yFrog", @""), self, NSLocalizedString(@"Cancel", @""), self.view);
		return;
	}
	
	suspendedOperation = noTEOperations;
	
	if(![[AccountManager manager] isValidLoggedUser])
	{
        [AccountController showAccountController:self.navigationController];
		return;
	}
	
	NSString *messageBody = messageText.text;
	if([self mediaIsPicked] && currentMediaYFrogURL)
	{
		messageBody = [messageBody stringByReplacingOccurrencesOfString:photoURLPlaceholderMask withString:currentMediaYFrogURL];
		messageBody = [messageBody stringByReplacingOccurrencesOfString:videoURLPlaceholderMask withString:currentMediaYFrogURL];
	}
	
	[TweetterAppDelegate increaseNetworkActivityIndicator];
	if(!self.progressSheet)
		self.progressSheet = ShowActionSheet(NSLocalizedString(@"Send twit on Twitter", @""), self, NSLocalizedString(@"Cancel", @""), 
                                             self.view);
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	postImageSegmentedControl.enabled = NO;
    
    NSString* mgTwitterConnectionID = [self sendMessage:messageBody];
	//if(_message)
	//	mgTwitterConnectionID = [_twitter sendUpdate:messageBody inReplyTo:[[_message objectForKey:@"id"] intValue]];
	//else if(_queueIndex >= 0)
	//	mgTwitterConnectionID = [_twitter sendUpdate:messageBody inReplyTo:_queuedReplyId];
	//else
	//	mgTwitterConnectionID = [_twitter sendUpdate:messageBody];
		
	MGConnectionWrap * mgConnectionWrap = [[MGConnectionWrap alloc] initWithTwitter:_twitter connection:mgTwitterConnectionID delegate:self];
	self.connectionDelegate = mgConnectionWrap;
	[mgConnectionWrap release];
	
	if(_queueIndex >= 0)
		[[TweetQueue sharedQueue] deleteMessage:_queueIndex];

	return;
}

- (NSString *)sendMessage:(NSString *)body
{
    NSString *conntectionID = nil;
    
	if(_message)
		conntectionID = [_twitter sendUpdate:body inReplyTo:[[_message objectForKey:@"id"] stringValue]];
	else if(_queueIndex >= 0)
    {
        NSNumber *statusID = [NSNumber numberWithInt:_queuedReplyId];
		conntectionID = [_twitter sendUpdate:body inReplyTo:[statusID stringValue]];
	}
    else
		conntectionID = [_twitter sendUpdate:body];
    return conntectionID;
}

- (BOOL)isDirectMessage
{
    return NO;
}

- (void)postImageLaterAction
{
	if(![self mediaIsPicked] && ![[messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
		return;

	if([messageText.text length] > MAX_SYMBOLS_COUNT_IN_TEXT_VIEW)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You can not send message", @"") 
														message:NSLocalizedString(@"Cant to send too long message", @"")
													   delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
		[alert show];
		[alert release];
		return;
	}

	NSString *messageBody = messageText.text;
	if([self mediaIsPicked] && currentMediaYFrogURL)
	{
		messageBody = [messageBody stringByReplacingOccurrencesOfString:photoURLPlaceholderMask withString:currentMediaYFrogURL];
		messageBody = [messageBody stringByReplacingOccurrencesOfString:videoURLPlaceholderMask withString:currentMediaYFrogURL];
	}

    NSString *username = nil;
    if ([self isDirectMessage])
        if ([self respondsToSelector:@selector(username)])
            username = [self performSelector:@selector(username)];
    
	BOOL added;
	if(_queueIndex >= 0)
	{
		added = [[TweetQueue sharedQueue] replaceMessage: messageBody 
                                               withImage: (pickedPhoto && !currentMediaYFrogURL) ? pickedPhoto : nil  
                                               withMovie: (pickedVideo && !currentMediaYFrogURL) ? pickedVideo : nil
                                               inReplyTo: _queuedReplyId
                                                 forUser: username
                                                 atIndex:_queueIndex];
	}
	else
	{
		added = [[TweetQueue sharedQueue] addMessage: messageBody 
                                           withImage: (pickedPhoto && !currentMediaYFrogURL) ? pickedPhoto : nil  
                                           withMovie: (pickedVideo && !currentMediaYFrogURL) ? pickedVideo : nil
                                           inReplyTo: _message ? [[_message objectForKey:@"id"] intValue] : 0
                                             forUser: username];
	}
	if(added)
	{
		if(connectionDelegate)
			[connectionDelegate cancel];
		[self setImage:nil movie:nil];
		[self setMessageTextText:@""];
		[messageText becomeFirstResponder];
		inTextEditingMode = YES;
		[self setNavigatorButtons];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!", @"") 
														message:NSLocalizedString(@"Cant to send too long message", @"")
													   delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
		[alert show];
		[alert release];
	}
}

- (IBAction)insertLocationAction
{	
	UIImage *theImage = nil;
	
	if (nil == self.location)
	{
		if ([self addLocation])
		{
			theImage = [UIImage imageNamed:@"mapRemove.tiff"];
		}
	}
	else
	{
		NSRange selectedRange = messageText.selectedRange;
		NSString *newLineWithLocation = [NSString stringWithFormat:@"%@%@", @"\n", self.location];
		
		NSRange notFoundRange = {NSNotFound, 0};
		NSRange stringRange = [messageText.text rangeOfString:newLineWithLocation];
		NSString *newText = nil;
		if (!NSEqualRanges(stringRange, notFoundRange))
		{
			newText = [messageText.text stringByReplacingOccurrencesOfString:newLineWithLocation withString:@""];			
		}
		else
		{
			newText = [messageText.text stringByReplacingOccurrencesOfString:self.location withString:@""];
		}
		
		[self setMessageTextText:newText];
		self.location = nil;
		messageText.selectedRange = selectedRange;
		theImage = [UIImage imageNamed:@"map.tiff"];
	}
	
	if (nil != theImage)
	{
		[locationSegmentedControl setImage:theImage forSegmentAtIndex:0];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet.tag == PHOTO_Q_SHEET_TAG)
	{
		if(buttonIndex == actionSheet.cancelButtonIndex)
			return;
		
		if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"RemoveImageTitle", @"")])
		{
            // PROGRESS
            [self progressClear];
            
			twitWasChangedManually = YES;
			[self setImage:nil movie:nil];
			if(connectionDelegate)
				[connectionDelegate cancel];
			self.currentMediaYFrogURL = nil;
			return;
		}
		else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Use photo camera", @"")])
		{
			ImagePickerController *imgPicker = [[ImagePickerController alloc] init];
			imgPicker.twitEditor = self;
			imgPicker.delegate = self;	
			imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			if([imgPicker respondsToSelector:@selector(setMediaTypes:)])
				[imgPicker performSelector:@selector(setMediaTypes:) withObject:[NSArray arrayWithObject:K_UI_TYPE_IMAGE]];
			[self presentModalViewController:imgPicker animated:YES];
			[imgPicker release];
			return;
		}
		else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Use video camera", @"")])
		{
			ImagePickerController *imgPicker = [[ImagePickerController alloc] init];
			imgPicker.twitEditor = self;
			imgPicker.delegate = self;			
			imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			if([imgPicker respondsToSelector:@selector(setMediaTypes:)])
				[imgPicker performSelector:@selector(setMediaTypes:) withObject:[NSArray arrayWithObject:K_UI_TYPE_MOVIE]];
			[self presentModalViewController:imgPicker animated:YES];
			[imgPicker release];
			return;
		}
		else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Use library", @"")])
		{
			ImagePickerController *imgPicker = [[ImagePickerController alloc] init];
			imgPicker.twitEditor = self;
			imgPicker.delegate = self;				
			imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			if([imgPicker respondsToSelector:@selector(setMediaTypes:)])
				[imgPicker performSelector:@selector(setMediaTypes:) withObject:[self availableMediaTypes:UIImagePickerControllerSourceTypePhotoLibrary]];
			[self presentModalViewController:imgPicker animated:YES];
			[imgPicker release];
			return;
		}
	}
	else
	{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
		suspendedOperation = noTEOperations;
		[self dismissProgressSheetIfExist];
		if(connectionDelegate)
			[connectionDelegate cancel];
        [cancelButton setEnabled:YES];
        [TweetterAppDelegate decreaseNetworkActivityIndicator];
	}
}

- (void)setRetwit:(NSString*)body whose:(NSString*)username
{
	if(username)
		[self setMessageTextText:[NSString stringWithFormat:NSLocalizedString(@"ReTwitFormat", @""), username, body]];
	else
		[self setMessageTextText:body];
}

- (void)setReplyToMessage:(NSDictionary*)message
{
	self._message = message;
	NSString *replyToUser = [[message objectForKey:@"user"] objectForKey:@"screen_name"];
	[self setMessageTextText:[NSString stringWithFormat:@"@%@ ", replyToUser]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent || self.navigationController.navigationBar.barStyle == UIBarStyleBlackOpaque) 
		postImageSegmentedControl.tintColor = [UIColor darkGrayColor];
	else
		postImageSegmentedControl.tintColor = defaultTintColor;
	if(!messageTextWillIgnoreNextViewAppearing)
	{
		[messageText becomeFirstResponder];
		inTextEditingMode = YES;
	}
	messageTextWillIgnoreNextViewAppearing = NO;
	[self setCharsCount];
	[self setNavigatorButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_canShowCamera)
    {
        _canShowCamera = NO;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
			ImagePickerController *imgPicker = [[ImagePickerController alloc] init];
			imgPicker.twitEditor = self;
			imgPicker.delegate = self;				
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if([imgPicker respondsToSelector:@selector(setMediaTypes:)])
                [imgPicker performSelector:@selector(setMediaTypes:) withObject:[NSArray arrayWithObjects:K_UI_TYPE_MOVIE, K_UI_TYPE_IMAGE, nil]];
            [self presentModalViewController:imgPicker animated:YES];
			[imgPicker release];
        }
    }
}

- (void)popController
{
	[self setImage:nil movie:nil];
	[self setMessageTextText:@""];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)imagesSegmentedActions:(id)sender
{
	switch([sender selectedSegmentIndex])
	{
		case 0:
			[self grabImage];
			break;
		case 1:
			[self setImage:nil movie:nil];
			if(connectionDelegate)
				[connectionDelegate cancel];
			self.currentMediaYFrogURL = nil;
			break;
		default:
			break;
	}
}

- (IBAction)postMessageSegmentedActions:(id)sender
{
	switch([sender selectedSegmentIndex])
	{
		case 0:
			[self postImageLaterAction];
			break;
		case 1:
			[self postImageAction];
			break;
		default:
			break;
	}
}

- (void)uploadedImage:(NSString*)yFrogURL sender:(ImageUploader*)sender
{
	[self releaseActivityIndicator];

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
	id userData = sender.userData;
	if(([userData isKindOfClass:[UIImage class]] && userData == pickedPhoto)    ||
		([userData isKindOfClass:[NSURL class]] && userData == pickedVideo)	) // don't kill later connection
	{
		self.connectionDelegate = nil;
		self.currentMediaYFrogURL = yFrogURL;
	}
	else if(![self mediaIsPicked])
	{
		self.connectionDelegate = nil;
		self.currentMediaYFrogURL = nil;
		self.pickedPhoto = nil;
		self.pickedVideo = nil;
		self.pickedPhotoData = nil;
		self.previewImage = nil;
	}
	else // another media was picked
		return;
	
	if(suspendedOperation == send)
	{
		suspendedOperation == noTEOperations;
		if(yFrogURL)
			[self postImageAction];
		else
		{
			[self dismissProgressSheetIfExist];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"")
                                                            message: NSLocalizedString(@"Error occure during uploading of image", @"")
														   delegate: nil 
                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"") 
                                                  otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}
	}
}

- (void)uploadedDataSize:(NSInteger)size
{
    _dataSize = size;
}

- (void)uploadedProccess:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten
{
    //float delta = (float)(totalBytesWritten) / (float)_dataSize;
    //[progress setProgress:delta];
    [self progressUpdate:totalBytesWritten];
}

- (void)imageUploadDidFailedBySender:(ImageUploader *)sender
{
	if(pickedPhoto)
	{
		[sender postData:self.pickedPhotoData delegate:self userData:pickedPhoto];
	}
}

- (BOOL)shouldChangeImage:(UIImage *)anImage withNewImage:(UIImage *)newImage
{
	[self setImage:newImage movie:nil];
	return YES;
}

#pragma mark MGTwitterEngineDelegate methods
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[self dismissProgressSheetIfExist];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"TwittsUpdated" object: nil];
	self.connectionDelegate = nil;
	image.image = nil;
	self.pickedPhoto = nil;
	self.pickedVideo = nil;
	self.pickedPhotoData = nil;
	self.previewImage = nil;
	[self setMessageTextText:@""];
	[messageText becomeFirstResponder];
	inTextEditingMode = YES;
	[self setNavigatorButtons];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	[self dismissProgressSheetIfExist];
	self.connectionDelegate = nil;
	postImageSegmentedControl.enabled = YES;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"")
                                                    message: [error localizedDescription]
												   delegate: nil 
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"") 
                                          otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (void)MGConnectionCanceled:(NSString *)connectionIdentifier
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	postImageSegmentedControl.enabled = YES;
	self.connectionDelegate = nil;
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	[self dismissProgressSheetIfExist];
}

- (void)doCancel
{
	[self.navigationController popViewControllerAnimated:YES];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	if(connectionDelegate)
		[connectionDelegate cancel];
	[self setImage:nil movie:nil];
	[self setMessageTextText:@""];
	[messageText resignFirstResponder];
	[self setNavigatorButtons];
}

- (IBAction)cancel
{
	if(!twitWasChangedManually || ([[messageText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 && ![self mediaIsPicked]))
	{
		[self doCancel];
		return;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"The message is not sent", @"") 
                                                    message:NSLocalizedString(@"Your changes will be lost", @"")
												   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                          otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
	alert.tag = PHOTO_DO_CANCEL_ALERT_TAG;
	[alert show];
	[alert release];
		
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == PHOTO_DO_CANCEL_ALERT_TAG)
	{
		if(buttonIndex > 0)
			[self doCancel];
	}
	else if(alertView.tag == PHOTO_ENABLE_SERVICES_ALERT_TAG)
	{
		if(buttonIndex > 0)
		{
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UseLocations"];
			[[LocationManager locationManager] startUpdates];
			[[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateLocationDefaultsChanged" object: nil];
		}
	}
}

- (void)editUnsentMessage:(int)index
{	
	NSString* text;
	NSData* imageData;
	NSURL* movieURL;
    NSString* username;
    
	if([[TweetQueue sharedQueue] getMessage:&text andImageData:&imageData movieURL:&movieURL inReplyTo:&_queuedReplyId forUser:&username atIndex:index])
	{
		_queueIndex = index;
		[self setMessageTextText:text];
		if(imageData)
			[self setImage:[UIImage imageWithData:imageData] movie:nil];
		else if(movieURL)
			[self setImage:nil movie:movieURL];
		[postImageSegmentedControl setTitle:NSLocalizedString(@"Save", @"") forSegmentAtIndex:0];
		[postImageSegmentedControl setWidth:postImageSegmentedControl.frame.size.width*0.5f
			forSegmentAtIndex:0];
	}
}

- (void)retainActivityIndicator
{
	if(++_indicatorCount == 1)
	{
		[image addSubview:_indicator];
		[_indicator startAnimating];
	}
}

- (void)releaseActivityIndicator
{
	if(_indicatorCount > 0)
	{
		[_indicator stopAnimating];
		[_indicator removeFromSuperview];
		--_indicatorCount;
	}
}

- (BOOL)mediaIsPicked
{
	return pickedPhoto || pickedVideo;
}

- (BOOL)addLocation
{
	if(![[LocationManager locationManager] locationServicesEnabled])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location service is not available on the device", @"") 
														message:NSLocalizedString(@"You can to enable Location Services on the device", @"")
													   delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
		[alert show];
		[alert release];
		return NO;
	}
	
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"UseLocations"])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location service was turn off in settings", @"") 
														message:NSLocalizedString(@"You can to enable Location Services in the application settings", @"")
													   delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
		alert.tag = PHOTO_ENABLE_SERVICES_ALERT_TAG;
		[alert show];
		[alert release];
		return NO;
	}
	
	if([[LocationManager locationManager] locationDenied])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Locations for this application was denied", @"") 
														message:NSLocalizedString(@"You can to enable Location Services by throw down settings", @"")
													   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	
	if(![[LocationManager locationManager] locationDefined])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location undefined", @"") 
														message:NSLocalizedString(@"Location is still undefined", @"")
													   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	
	NSString* mapURL = [NSString stringWithFormat:
						NSLocalizedString(@"LocationLinkFormat", @""), [[LocationManager locationManager] mapURL]];
	NSRange selectedRange = messageText.selectedRange;
	if (nil == self.location)
	{
		[self setMessageTextText:[NSString stringWithFormat:@"%@\n%@", messageText.text, mapURL]];
	}
	else
	{
		NSString *newText = [messageText.text stringByReplacingOccurrencesOfString:self.location withString:mapURL];
		[self setMessageTextText:newText];
	}
	
	self.location = mapURL;
	messageText.selectedRange = selectedRange;
	return YES;
}

@end
