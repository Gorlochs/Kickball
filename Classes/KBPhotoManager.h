//
//  PhotoManager.h
//  Kickball
//
//  Created by Shawn Bernard on 5/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect/FBConnect.h"
#import "ASINetworkQueue.h"
#import "FSVenue.h"
#import "PhotoManagerDelegate.h"


@interface KBPhotoManager : NSObject <FBRequestDelegate> {
    id <PhotoManagerDelegate> delegate;
    ASINetworkQueue *networkQueue;
    
    NSString *photoTextPlaceholder;  // this is necessary for when the user takes a photo. the view is unloaded, so the textview needs to store the text somewhere
}

@property (retain, nonatomic) id <PhotoManagerDelegate> delegate;
@property (retain, nonatomic) NSString *photoTextPlaceholder;

+ (KBPhotoManager*) sharedInstance;
- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename withWidth:(float)width andHeight:(float)height 
         andMessage:(NSString*)message andOrientation:(UIImageOrientation)orientation andVenue:(FSVenue*)venue;
- (UIImage*)imageByScalingToSize:(UIImage*)image toSize:(CGSize)targetSize;
- (void) uploadFacebookPhoto:(NSData*)img withCaption:(NSString*)caption;

@end
