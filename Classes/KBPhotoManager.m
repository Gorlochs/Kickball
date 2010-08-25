//
//  PhotoManager.m
//  Kickball
//
//  Created by Shawn Bernard on 5/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBPhotoManager.h"
#import "ASIFormDataRequest.h"
#import "FBConnect/FBRequest.h"
#import "KBLocationManager.h"
#import "KBMessage.h"
#import "FlurryAPI.h"
#import "FoursquareAPI.h"
#import "FacebookProxy.h"


static inline double radians (double degrees) {return degrees * M_PI/180;}
static KBPhotoManager *photoManager = nil;
static BOOL initialized = NO;

@interface KBPhotoManager (Private)


@end
 

@implementation KBPhotoManager

@synthesize delegate;
@synthesize photoTextPlaceholder;

+ (KBPhotoManager*) sharedInstance {
	if(!photoManager)  {
        photoManager = [[KBPhotoManager allocWithZone:nil] init];
    }
    
	return photoManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
		if (photoManager == nil) 
			photoManager = [super allocWithZone:zone];
    }
	
    return photoManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
	if(initialized)
		return photoManager;
	
	self = [super init];
    if (!self)
	{
		if(photoManager)
			[photoManager release];
		return nil;
	}
    
    // Initilize Queue
    networkQueue = [[ASINetworkQueue alloc] init];
    //[networkQueue setUploadProgressDelegate:statusProgressView];
    [networkQueue setRequestDidFinishSelector:@selector(imageRequestDidFinish:)];
    [networkQueue setQueueDidFinishSelector:@selector(imageQueueDidFinish:)];
    [networkQueue setRequestDidFailSelector:@selector(imageRequestDidFail:)];
    [networkQueue setShowAccurateProgress:true];
    [networkQueue setDelegate:self];
    
	initialized = YES;
    
    photoTextPlaceholder = @"";
    
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (void) imageRequestDidFinish:(ASIHTTPRequest *) request {
    [delegate photoUploadFinished:request];
//    [self stopProgressBar];
    DLog(@"PhotoManager - YAY! Image uploaded! %@", [request responseString]);
//    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Image upload has been completed!"];
//    [self displayPopupMessage:message];
//    [message release];
//    
//    // NOTE: the self.photoMessageToPush is being set above in the returnFromMessageView: method
//    self.venueToPush = self.venue;
//    self.hasPhoto = YES;
//    //[self sendPushNotification];
//    [FlurryAPI logEvent:@"Image Upload Completed"];
}

- (void) imageQueueDidFinish:(ASIHTTPRequest *) request {
    [delegate photoQueueFinished:request];
//    [self stopProgressBar];
    DLog(@"PhotoManager - YAY! Image queue is complete!");
//    
//    // TODO: this should probably capture the response, parse it into a KBGoody, then add it to the goodies object - it would save an API hit
//    
//    [self retrievePhotos];
}

- (void) imageRequestDidFail:(ASIHTTPRequest *) request {
    [delegate photoUploadFailed:request];
//    [self stopProgressBar];
    DLog(@"PhotoManager - Uhoh, it did fail!");
}

- (void) imageRequestWentWrong:(ASIHTTPRequest *) request {
//    [self stopProgressBar];
    DLog(@"PhotoManager - Uhoh, request went wrong!");
}

-(UIImage*)imageByScalingToSize:(UIImage*)image toSize:(CGSize)targetSize {
	
	CGImageRef imgRef = image.CGImage;  
	
	CGFloat width = CGImageGetWidth(imgRef);  
	CGFloat height = CGImageGetHeight(imgRef);  
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);  
	int maxDimension = targetSize.width;
	if(maxDimension > 0) //need scale
	{
		if (width > maxDimension || height > maxDimension) 
		{  
			CGFloat ratio = width/height;  
			if (ratio > 1)
			{  
				bounds.size.width = maxDimension;  
				bounds.size.height = bounds.size.width / ratio;  
			}  
			else
			{  
				bounds.size.height = maxDimension;  
				bounds.size.width = bounds.size.height * ratio;  
			}  
		}
	}
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
    CGFloat boundHeight;  
	
	UIImageOrientation orient = image.imageOrientation;  
    switch(orient) 
	{  
        case UIImageOrientationUp: //EXIF = 1  
            transform = CGAffineTransformIdentity;  
            break;  
			
        case UIImageOrientationUpMirrored: //EXIF = 2  
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            break;  
			
        case UIImageOrientationDown: //EXIF = 3  
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
            transform = CGAffineTransformRotate(transform, M_PI);  
            break;  
			
        case UIImageOrientationDownMirrored: //EXIF = 4  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
            transform = CGAffineTransformScale(transform, 1.0, -1.0);  
            break;  
			
        case UIImageOrientationLeftMirrored: //EXIF = 5  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
			
        case UIImageOrientationLeft: //EXIF = 6  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
			
        case UIImageOrientationRightMirrored: //EXIF = 7  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeScale(-1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
			
        case UIImageOrientationRight: //EXIF = 8  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
			
        default:  
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
			
    }  
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();  
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
	{
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);  
    }
    else
	{  
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);  
    }  
	
    CGContextConcatCTM(context, transform);  
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
	
    return imageCopy;

	
	/*
	UIImage* sourceImage = image; 
	CGFloat targetMax = targetSize.width;
	
	CGImageRef imageRef = [sourceImage CGImage];
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
	if (bitmapInfo == kCGImageAlphaNone) {
		bitmapInfo = kCGImageAlphaNoneSkipLast;
	}
	
	CGContextRef bitmap;
	CGFloat targetWidth;
	CGFloat targetHeight;
	if(image.size.width==image.size.height){
		//square
		targetWidth = targetMax;
		targetHeight = targetMax;
	}else if (image.size.width > image.size.height) {
		//landscape
		targetWidth = targetMax;
		targetHeight = (targetMax * image.size.height)/image.size.width;
	}else {
		//portrait
		targetWidth = (targetMax * image.size.width)/image.size.height;
		targetHeight = targetMax;
	}
	
	bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);


	
}

-(UIImage*)imageByScalingToSize:(UIImage*)image toSize:(CGSize)targetSize {
	UIImage* sourceImage = image; 
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
    
	CGImageRef imageRef = [sourceImage CGImage];
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
	if (bitmapInfo == kCGImageAlphaNone) {
		bitmapInfo = kCGImageAlphaNoneSkipLast;
	}
	
	CGContextRef bitmap;
	
	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
	} else {
		bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
	}	
	
	
	// In the right or left cases, we need to switch scaledWidth and scaledHeight,
	// and also the thumbnail point
	if (sourceImage.imageOrientation == UIImageOrientationLeft) {
		//CGContextRotateCTM (bitmap, radians(90));
		//CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
	} else if (sourceImage.imageOrientation == UIImageOrientationUp) {
		// NOTHING
		// This is the default value
		//need to check for 
	} else if (sourceImage.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
		CGContextRotateCTM (bitmap, radians(-180.));
	}
	
	//this needs to be way more complex...
	CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
	
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return newImage; 
	 */
}

// TODO: set max file size    
- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename withWidth:(float)width andHeight:(float)height 
         andMessage:(NSString*)message andOrientation:(UIImageOrientation)orientation andVenue:(FSVenue*)venue {
    
    NSNumber *tagKey = [NSNumber numberWithInteger:1];
    
    // Initilize Variables
    NSURL *url = nil;
    ASIFormDataRequest *request = nil;
    
    // Return if there is no image
    if(imageData != nil){
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gifts.json", @"http://kickball.gorlochs.com/kickball"]];
        request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
        if (venue) {
            [request setPostValue:venue.venueid forKey:@"gift[venue_id]"];
            [request setPostValue:venue.name forKey:@"gift[venue_name]"];   
        } else {
            [request setPostValue:venue.venueid forKey:@"-1"];
            [request setPostValue:venue.name forKey:@"twitter"];
        }
        [request setPostValue:[[FoursquareAPI sharedInstance] currentUser].userId forKey:@"gift[owner_id]"];
        //        [request setPostValue:@"" forKey:@"gift[recipient_id]"];
        [request setPostValue:@"1" forKey:@"gift[is_public]"];
        [request setPostValue:@"0" forKey:@"gift[is_banned]"];
        [request setPostValue:@"0" forKey:@"gift[is_flagged]"];
        [request setPostValue:[NSString stringWithFormat:@"%f", [[KBLocationManager locationManager] latitude]] forKey:@"gift[latitude]"];
        [request setPostValue:[NSString stringWithFormat:@"%f", [[KBLocationManager locationManager] longitude]] forKey:@"gift[longitude]"];
        [request setPostValue:[NSString stringWithFormat:@"%d", (int)height]  forKey:@"gift[photo_height]"];
        [request setPostValue:[NSString stringWithFormat:@"%d", (int)width] forKey:@"gift[photo_width]"];
        [request setPostValue:[[FoursquareAPI sharedInstance] currentUser].firstnameLastInitial forKey:@"gift[owner_name]"];
        [request setPostValue:message ? message : @"" forKey:@"gift[message_text]"];
        [request setPostValue:[tagKey stringValue] forKey:@"gift[iphone_orientation]"];
		if ([filename isEqualToString:@"tweet.jpg"]) {
			[request setData:imageData withFileName:filename andContentType:@"image/jpeg" forKey:@"gift[photo]"];
		} else {
			[request setData:imageData withFileName:filename andContentType:@"image/png" forKey:@"gift[photo]"];
		}
        [request setDidFailSelector:@selector(imageRequestWentWrong:)];
        [request setTimeOutSeconds:500];
        [networkQueue addOperation:request];
        //queueCount++;
    }
    [networkQueue go];
    
    return YES;
}

- (void) uploadFacebookPhoto:(NSData*)img withCaption:(NSString*)caption {
    NSDictionary *params = nil;
    if (caption) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:caption, @"caption", nil];
    }
    [[FBRequest requestWithDelegate:self] call:@"facebook.photos.upload" params:params dataParam:(NSData*)img];
}

- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([request.method isEqualToString:@"facebook.photos.upload"]) {
        NSDictionary* photoInfo = result;
        NSString* pid = [photoInfo objectForKey:@"pid"];
        DLog(@"facebook photo uploaded: %@", photoInfo);
        DLog(@"facebook photo uploaded. pid: %@", pid);
    }
}

@end
