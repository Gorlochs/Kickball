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

#import <UIKit/UIKit.h>
#import "TwitterConnectionProtocol.h"
#import "yFrogImageUploader.h"
#import "MGConnectionWrap.h"
#import "ImagePreview.h"

@class MGTwitterEngine;
@class TwitEditorController;

enum _TwitEditorSuspendedOperations
{
	noTEOperations,
	send
} typedef TwitEditorSuspendedOperations;


@interface ImagePickerController : UIImagePickerController
{
@private
	TwitEditorController *twitEditor;
}

@property (nonatomic, assign) TwitEditorController *twitEditor;

@end

@interface TwitEditorController : UIViewController  <UINavigationControllerDelegate, 
													UIImagePickerControllerDelegate, 
													UITextViewDelegate, ImageUploaderDelegate,
                                                    UIActionSheetDelegate, MGConnectionDelegate, 
                                                    UIAlertViewDelegate> 
{
	UISegmentedControl *pickImage;
    UIBarButtonItem *cancelButton;
    UINavigationItem *navItem;
    ImagePreview *image;
    UITextView *messageText;
    UILabel *charsCount;
    UIProgressView *progress;
    UILabel *progressStatus;
	BOOL			inTextEditingMode;

	UIActionSheet *progressSheet;
	UISegmentedControl *postImageSegmentedControl;
	UIBarButtonItem *segmentBarItem;
	UISegmentedControl *imagesSegmentedControl;
	UISegmentedControl *locationSegmentedControl;
	UIColor *defaultTintColor;
	
	NSString* currentMediaYFrogURL;
	id <TwitterConnectionProtocol>  connectionDelegate;
	TwitEditorSuspendedOperations suspendedOperation;

	NSString*				photoURLPlaceholderMask;
	NSString*				videoURLPlaceholderMask;
	
	NSString*				location;
	
	MGTwitterEngine *		_twitter;
	
	BOOL					messageTextWillIgnoreNextViewAppearing;

	NSDictionary*			_message;
	
	int						_queueIndex;
	int						_queuedReplyId;
	
	UIActivityIndicatorView *_indicator;
	int						_indicatorCount;
	
	BOOL					twitWasChangedManually;
	
	NSURL*					pickedVideo;
	UIImage*				pickedPhoto;
	UIImage*				previewImage;
	NSData*					pickedPhotoData;
    
    int                     _dataSize;
    BOOL                    _canShowCamera;
	
	int imageDimension;
	int imageRotationAngle;
}

- (id)init;
- (id)initInCameraMode;

- (void)postImageAction;
- (void)postImageLaterAction;
- (IBAction)insertLocationAction;
- (IBAction)cancel;
- (void)grabImage;

- (void)progressClear;
- (void)progressUpdate:(NSInteger)bytesWritten;

- (void)setRetwit:(NSString*)body whose:(NSString*)username;
- (void)setReplyToMessage:(NSDictionary*)message;
- (void)editUnsentMessage:(int)index;

- (IBAction)imagesSegmentedActions:(id)sender;
- (IBAction)attachImagesActions:(id)sender;
- (IBAction)postMessageSegmentedActions:(id)sender;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;
- (void)textViewDidBeginEditing:(UITextView *)textView;

- (NSString *)sendMessage:(NSString *)body;
- (BOOL)isDirectMessage;

- (void)popController;

- (void)startUploadingOfPickedMediaIfNeed;
- (void)uploadedImage:(NSString*)yFrogURL sender:(ImageUploader*)sender;
- (void)uploadedDataSize:(NSInteger)size;
- (void)uploadedProccess:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten;

- (void)retainActivityIndicator;
- (void)releaseActivityIndicator;

- (BOOL)mediaIsPicked;
- (BOOL)addLocation;

@property (nonatomic, retain) UIActionSheet *progressSheet;
@property (nonatomic, retain) NSString *currentMediaYFrogURL;
@property (nonatomic, retain) id <TwitterConnectionProtocol> connectionDelegate;
@property (nonatomic, retain) NSDictionary *_message;
@property (nonatomic, retain) NSURL *pickedVideo;
@property (nonatomic, retain) UIImage *pickedPhoto;
@property (nonatomic, retain) UIImage *previewImage;
@property (nonatomic, retain) NSData *pickedPhotoData;
@property (nonatomic, retain) NSString *location;

@property (nonatomic, retain) IBOutlet UISegmentedControl *pickImage;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) IBOutlet ImagePreview *image;
@property (nonatomic, retain) IBOutlet UITextView *messageText;
@property (nonatomic, retain) IBOutlet UILabel *charsCount;
@property (nonatomic, retain) IBOutlet UIProgressView *progress;
@property (nonatomic, retain) IBOutlet UILabel *progressStatus;
@property (nonatomic, retain) IBOutlet UISegmentedControl *postImageSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *imagesSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *locationSegmentedControl;

@end
