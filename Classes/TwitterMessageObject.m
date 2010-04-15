//
//  TwitterMessageObject.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 12/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "TwitterMessageObject.h"

@implementation TwitterMessageObject

@synthesize messageId = _messageId;
@synthesize username = _username;
@synthesize screenname = _screenname;
@synthesize message = _message;
@synthesize location = _location;
@synthesize description = _description;
@synthesize creationFormattedDate = _creationFormattedDate;
@synthesize creationDate = _creationDate;
@synthesize avatarUrl = _avatarUrl;
@synthesize avatar = _avatar;
@synthesize isFavorite = _isFavorite;
@synthesize yfrogLinks = _yfrogLinks;
@synthesize yfrogThumbnails = _yfrogThumbnails;

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (void)dealloc
{
    self.messageId = nil;
    self.username = nil;
    self.screenname = nil;
    self.message = nil;
    self.location = nil;
    self.description = nil;
    self.creationFormattedDate = nil;
    self.creationDate = nil;
    self.avatarUrl = nil;
    self.avatar = nil;
    self.yfrogLinks = nil;
    self.yfrogThumbnails = nil;
    [super dealloc];
}

@end
