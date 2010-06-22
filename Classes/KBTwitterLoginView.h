//
//  KBTwitterLoginView.h
//  Kickball
//
//  Created by scott bates on 6/22/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XAuthTwitterEngineDelegate.h"
#import "OAToken.h"
#import "KBFoursquareLoginView.h"

#define kOAuthConsumerKey		@"qyx7QFTRxkJ0BbYN6ZKqbg"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"5Naqknb57AxYWVdonjl0H9Iod7Kq76MWcvnYqAEpo"		// and consumer secret from http://twitter.com/oauth_clients/details/<your app id>
#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"

@class XAuthTwitterEngine;

@interface KBTwitterLoginView : KBFoursquareLoginView <XAuthTwitterEngineDelegate>{
	XAuthTwitterEngine *twitterEngine;

}
@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;


@end
