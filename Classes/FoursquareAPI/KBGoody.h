//
//  FSGift.h
//  Kickball
//
//  Created by Shawn Bernard on 2/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBGoody : NSObject {
    NSString *imagePath;
    NSString *thumbnailImagePath;
    NSString *mediumImagePath;
    NSString *imageName;
    NSString *recipientId;
    NSString *venueId;
    NSString *ownerId;
    NSString *messageText;
    BOOL isBanned;
    BOOL isPublic;
    NSDate *createdAt;
    NSString *goodyId;
}

@property (nonatomic, retain) NSString *imagePath;
@property (nonatomic, retain) NSString *thumbnailImagePath;
@property (nonatomic, retain) NSString *mediumImagePath;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *recipientId;
@property (nonatomic, retain) NSString *venueId;
@property (nonatomic, retain) NSString *ownerId;
@property (nonatomic, retain) NSString *messageText;
@property (nonatomic) BOOL isBanned;
@property (nonatomic) BOOL isPublic;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *goodyId;

@end
