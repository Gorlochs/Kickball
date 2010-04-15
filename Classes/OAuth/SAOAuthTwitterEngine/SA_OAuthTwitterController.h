//
//  SA_OAuthTwitterController.h
//
//  Created by Ben Gottlieb on 24 July 2009.
//  Copyright 2009 Stand Alone, Inc.
//
//  Some code and concepts taken from examples provided by 
//  Matt Gemmell, Chris Kimpton, and Isaiah Carew
//  See ReadMe for further attributions, copyrights and license info.
//

#import <UIKit/UIKit.h>

@class XAuthTwitterEngine, SA_OAuthTwitterController;

@protocol SA_OAuthTwitterControllerDelegate <NSObject>
@optional
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username;
- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller;
- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller;
@end


@interface SA_OAuthTwitterController : UIViewController <UIWebViewDelegate> {

	XAuthTwitterEngine						*_engine;
	UIWebView									*_webView;
	UINavigationBar								*_navBar;
	UIImageView									*_backgroundView;
	
	id <SA_OAuthTwitterControllerDelegate>		_delegate;
	UIActivityIndicatorView						*_activityIndicator;
}


@property (nonatomic, readwrite, retain) XAuthTwitterEngine *engine;
@property (nonatomic, readwrite, assign) id <SA_OAuthTwitterControllerDelegate> delegate;
@property (nonatomic, readonly) UINavigationBar *navigationBar;

+ (SA_OAuthTwitterController *) controllerToEnterCredentialsWithTwitterEngine: (XAuthTwitterEngine *) engine delegate: (id <SA_OAuthTwitterControllerDelegate>) delegate;
+ (BOOL) credentialEntryRequiredWithTwitterEngine: (XAuthTwitterEngine *) engine;


- (id) initWithEngine: (XAuthTwitterEngine *) engine;
@end
