//
//  XAuthTwitterEngineViewController.h
//  XAuthTwitterEngineDemo
//
//  Created by Aral Balkan on 28/02/2010.
//  Copyright Naklab 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XAuthTwitterEngineDelegate.h"
#import "OAToken.h"


#define kOAuthConsumerKey		@"qyx7QFTRxkJ0BbYN6ZKqbg"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"5Naqknb57AxYWVdonjl0H9Iod7Kq76MWcvnYqAEpo"		// and consumer secret from http://twitter.com/oauth_clients/details/<your app id>
#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"

@class XAuthTwitterEngine;

@interface KBTwitterXAuthLoginController : UIViewController <XAuthTwitterEngineDelegate, UITextFieldDelegate> {
	IBOutlet UITextField *twitterUsername;
	IBOutlet UITextField *twitterPassword;
    XAuthTwitterEngine *twitterEngine;
	UIViewController * rootController;
}

@property (nonatomic, retain) UITextField *twitterUsername, *twitterPassword;
@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) UIViewController *rootController;

- (IBAction)xAuthAccessTokenRequestButtonTouchUpInside;
- (IBAction) noThankYou;

@end

