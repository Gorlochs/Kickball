//
//  FSGift.m
//  Kickball
//
//  Created by Shawn Bernard on 2/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBGoody.h"

#define kLargePhotoMaxSize 480.0f


@implementation KBGoody

@synthesize imagePath;
@synthesize thumbnailImagePath;
@synthesize mediumImagePath;
@synthesize largeImagePath;
@synthesize imageName;
@synthesize recipientId;
@synthesize venueId;
@synthesize ownerId;
@synthesize messageText;
@synthesize isBanned;
@synthesize isPublic;
@synthesize createdAt;
@synthesize goodyId;
@synthesize ownerName;
@synthesize venueName;
@synthesize imageHeight;
@synthesize imageWidth;

- (NSString*) imagePath {
    return [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/original/%@.jpg", goodyId, goodyId];
}

- (NSString*) thumbnailImagePath {
    return [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/thumb/%@.jpg", goodyId, goodyId];
}

- (NSString*) mediumImagePath {
    return [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/medium/%@.jpg", goodyId, goodyId];
}

- (NSString*) largeImagePath {
    return [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/large/%@.jpg", goodyId, goodyId];
}

- (CGSize) largeImageSize {
    float ratio = self.imageWidth > self.imageHeight ? (float)self.imageWidth / kLargePhotoMaxSize : (float)self.imageHeight / kLargePhotoMaxSize;
    NSLog(@"ratio: %f", ratio);
    if (ratio < 1) {
        ratio = 1;
    }
    return CGSizeMake(self.imageWidth/ratio, self.imageHeight/ratio);
}

- (void)dealloc {
    [super dealloc];
}


@end
