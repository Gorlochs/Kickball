//
//  PhotoManagerDelegate.h
//  Kickball
//
//  Created by Shawn Bernard on 5/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@protocol PhotoManagerDelegate

- (void) photoUploadFinished:(ASIHTTPRequest*) request;
- (void) photoUploadFailed:(ASIHTTPRequest*) request;
- (void) photoQueueFinished:(ASIHTTPRequest*) request;

@end
