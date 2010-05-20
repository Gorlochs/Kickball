//
//  PhotoManager.h
//  Kickball
//
//  Created by Shawn Bernard on 5/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoManagerDelegate.h"


@interface PhotoManager : NSObject {
    id <PhotoManagerDelegate> delegate;
}

@property (retain, nonatomic) id <PhotoManagerDelegate> delegate;

+ (PhotoManager*) sharedInstance;

@end
