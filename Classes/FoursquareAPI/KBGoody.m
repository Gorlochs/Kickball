//
//  FSGift.m
//  Kickball
//
//  Created by Shawn Bernard on 2/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBGoody.h"


@implementation KBGoody

@synthesize imagePath;
@synthesize thumbnailImagePath;
@synthesize mediumImagePath;
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

- (NSString*) imagePath {
    return [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/original/%@.jpg", goodyId, goodyId];
}

- (NSString*) thumbnailImagePath {
    return [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/thumb/%@.jpg", goodyId, goodyId];
}

- (NSString*) mediumImagePath {
    return [NSString stringWithFormat:@"https://kickball.s3.amazonaws.com/photos/%@/medium/%@.jpg", goodyId, goodyId];
}

- (void)dealloc {
    [super dealloc];
}


@end
