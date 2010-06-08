//
//  KBAccountManager.h
//  Kickball
//
//  Created by Shawn Bernard on 5/21/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KBAccountManager : NSObject {
    BOOL usesTwitter;
    BOOL usesFacebook;
	BOOL shouldPostPhotosToFacebook;
}

@property (nonatomic) BOOL usesTwitter;
@property (nonatomic) BOOL usesFacebook;
@property (nonatomic) BOOL shouldPostPhotosToFacebook;

+ (KBAccountManager*)sharedInstance;
- (BOOL) usesFacebookOrHasNotDecided;
- (BOOL) usesTwitterOrHasNotDecided;

@end
