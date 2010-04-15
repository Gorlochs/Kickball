//
//  TwitterMessageObject.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 12/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterMessageObject : NSObject {
@private
    NSString    *_messageId;
    NSString    *_username;
    NSString    *_screenname;
    NSString    *_message;
    NSString    *_location;
    NSString    *_description;
    NSString    *_creationFormattedDate;
    NSDate      *_creationDate;
    NSString    *_avatarUrl;
    UIImage     *_avatar;
    BOOL         _isFavorite;
    NSArray     *_yfrogLinks;
    NSArray     *_yfrogThumbnails;
}

@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *screenname;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *creationFormattedDate;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *avatarUrl;
@property (nonatomic, retain) UIImage *avatar;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, retain) NSArray *yfrogLinks;
@property (nonatomic, retain) NSArray *yfrogThumbnails;

- (id)init;

@end
