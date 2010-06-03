//
//  KBTwitterManager.h
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XAuthTwitterEngine.h"
#import "KBTwitterManagerDelegate.h"

#define kOAuthConsumerKey		@"qyx7QFTRxkJ0BbYN6ZKqbg"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"5Naqknb57AxYWVdonjl0H9Iod7Kq76MWcvnYqAEpo"		// and consumer secret from http://twitter.com/oauth_clients/details/<your app id>
#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"

#define kTwitterLoginNotificationKey                @"loginNotification"
#define kTwitterStatusRetrievedNotificationKey      @"statusRetrievedNotification"
#define kTwitterDMRetrievedNotificationKey          @"directMessagesRetrievedNotification"
#define kTwitterUserInfoRetrievedNotificationKey    @"userInfoRetrievedNotification"
#define kTwitterMiscRetrievedNotificationKey        @"miscellaneousRetrievedNotification"
#define kTwitterSearchRetrievedNotificationKey      @"searchRetrievedNotification"

#define kKBTwitterTimelineKey           @"timeline"
#define kKBTwitterMentionsKey           @"mentions"
#define kKBTwitterDirectMessagesKey     @"directMessage"
#define kKBTwitterGeoTweetKey           @"geoTweet"


@interface KBTwitterManager : NSObject {
	id <KBTwitterManagerDelegate> delegate;
    XAuthTwitterEngine *twitterEngine;
    BOOL hasGeoTweetTurnedOn;
    NSArray *theSearchResults;
    NSString *searchTerm;
}

@property (retain, nonatomic) id <KBTwitterManagerDelegate> delegate;
@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) NSArray *theSearchResults;
@property (nonatomic, retain) NSString *searchTerm;
@property (nonatomic) BOOL hasGeoTweetTurnedOn;

+ (KBTwitterManager*) twitterManager;

- (void) cacheStatusArray:(NSArray*)statuses withKey:(NSString*)key;
- (NSArray*) retrieveCachedStatusArrayWithKey:(NSString*)key;

@end

