//
//  PhotoManager.m
//  Kickball
//
//  Created by Shawn Bernard on 5/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PhotoManager.h"


static PhotoManager *photoManager = nil;

@implementation PhotoManager

+ (PhotoManager*) sharedInstance {
	if(!photoManager)  {
        photoManager = [[PhotoManager allocWithZone:nil] init];
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


@end
