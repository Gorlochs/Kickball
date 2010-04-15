// Copyright (c) 2009 Imageshack Corp.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "LoginController.h"
#import "WebViewController.h"
#import "UserAccount.h"
#import "MGTwitterEngine.h"
#include "config.h"
#include "util.h"

//#define AccountSegmentIndex     0
//#define OAuthSegmentIndex       1

#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"

const NSString *kNewAccountLoginDataKey = @"newAccount";
const NSString *kOldAccountLoginDataKey = @"oldAccount";

const NSString *LoginControllerAccountDidChange = @"LoginControllerAccountDidChange";

@implementation LoginController

@synthesize usernameTextField, passwordTextField, sendTweetButton, twitterEngine;

- (id)init
{
//    if (self = [super initWithNibName:@"Login" bundle:nil])
	self = [super init];
	if (nil != self)
    {
        _currentAccount = nil;
//        oAuthAuthorization = NO;
		oAuthAuthorization = YES;
        
        NSLog(@"logincontroller init");
    }
    return self;
}

- (id)initWithUserAccount:(UserAccount*)account
{
    if (self = [self init])
    {
        _currentAccount = [account retain];
    }
    return self;
}

- (void)dealloc
{
    [_currentAccount release];
    [super dealloc];
}

- (IBAction)cancel:(id)sender 
{
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)processAccountInfo
{
    // Create new UserAccount object and send it as parameter of notification
    UserAccount *newAccount = [[UserAccount alloc] init];
//    newAccount.username = [loginField text];
//    newAccount.secretData = [passwordField text];
    // Notification parameters
    NSDictionary *loginData = [NSDictionary dictionaryWithObjectsAndKeys: newAccount, kNewAccountLoginDataKey, _currentAccount, kOldAccountLoginDataKey, nil];
    [newAccount release];
    // Post LoginControllerAccountDidChange notifiaction
    [[NSNotificationCenter defaultCenter] postNotificationName: (NSString *)LoginControllerAccountDidChange 
                                                        object: nil
                                                      userInfo: loginData];
    // Pop self controller from navigation bar
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login:(id)sender
{
//    twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
//    [MGTwitterEngine setUsername:[loginField text] password:[passwordField text]];
//    twitterUserCredentialID = [twitter checkUserCredentials];
//    [loginField resignFirstResponder];
//    [passwordField resignFirstResponder];
    // Show progress indicator
//    progress = [[TwActivityIndicator alloc] init];
//    [progress.messageLabel setText:NSLocalizedString(@"Account_Verification", @"")];
//    [progress show];
//    self.navigationItem.rightBarButtonItem.enabled = NO;
//    self.navigationItem.leftBarButtonItem.enabled = NO;
//    [authTypeSegment setEnabled:NO forSegmentAtIndex:0];
//    [authTypeSegment setEnabled:NO forSegmentAtIndex:1];
}

//- (IBAction)changeAuthTypeClick:(id)sender
//{
//    UISegmentedControl *segmentSender = (UISegmentedControl*)sender;
//    
//    if (segmentSender)
//    {
//        // Select authentification via login/password.
//        if (segmentSender.selectedSegmentIndex == AccountSegmentIndex)
//        {
//            self.view = accountView;
//            self.navigationItem.rightBarButtonItem.enabled = YES;
//        }
//        // Selecte authentification via OAuth. Load twitter.com in inapp web browser.
//        else if (segmentSender.selectedSegmentIndex == OAuthSegmentIndex)
//        {
//            self.view = oAuthView;
//            self.navigationItem.rightBarButtonItem.enabled = NO;			
//        }
//    }
//}

//- (IBAction)oAuthOKClick
//{
//    SA_OAuthTwitterEngine *engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
//    
//    engine.consumerKey = kTweeteroConsumerKey;
//    engine.consumerSecret = kTweeteroConsumerSecret;
//    
//    [engine requestRequestToken];
//    
//    SA_OAuthTwitterController *oAuthController = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:engine delegate:self];
//    
//    if (oAuthController)
//        [self.navigationController pushViewController:oAuthController animated:YES];
//    else
//		[engine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
//}

- (void)showOAuthViewInController:(UINavigationController *)aNavigationController
{
    self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
//    SA_OAuthTwitterEngine *engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
    self.twitterEngine.consumerKey = kTweeteroConsumerKey;
    self.twitterEngine.consumerSecret = kTweeteroConsumerSecret;
    
    if ([self.twitterEngine isAuthorized])
	{
		UIAlertViewQuick(@"Cached xAuth token found!", @"This app was previously authorized for a Twitter account so you can press the second button to send a tweet now.", @"OK");
		self.sendTweetButton.enabled = YES;
	}
    
    //[engine requestRequestToken];
    
    SA_OAuthTwitterController *oAuthController = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:self.twitterEngine delegate:self];
    if (oAuthController)
	{
		[aNavigationController pushViewController:oAuthController animated:YES];
	}
    else
	{
		[self.twitterEngine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
	}
}

- (void)loadView
{
    //[super viewDidLoad];
    [super loadView];
//    accountView = self.view;
    
// 	self.navigationItem.rightBarButtonItem = loginButton;
//  self.navigationItem.leftBarButtonItem = cancelButton;
//  self.navigationItem.titleView = authTypeSegment;
    
//    if (_currentAccount)
//    {
//        [loginField setText:_currentAccount.username];
//        [passwordField setText:@""];
//        [rememberSwitch setOn: NO];
//    }
    
    //self.navigationItem.leftBarButtonItem = nil;
    
//	UIImage *icon = [UIImage imageNamed:@"Frog.tiff"];
//	if(icon)
//		[iconView setImage:icon];
//		
//	[oAuthOKButton setBackgroundImage:[UIImage imageNamed:@"oAuthButton.png"] forState:UIControlStateNormal];
//    oAuthOKButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//	oAuthOKButton.frame = CGRectInset(oAuthOKButton.frame, -10, -15);
//	oAuthOKButton.titleLabel.textColor = [UIColor whiteColor];	
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (_currentAccount)
//    {
//        UISegmentedControl *seg = authTypeSegment;
//        
//        [seg setSelectedSegmentIndex:_currentAccount.authType];
//        [self changeAuthTypeClick:seg];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (oAuthAuthorization)
        [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark <UITextFieldDelegate> Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    return YES;
}

//#pragma mark OAuth delegate
//- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username 
//{
//    UserAccount *newAccount = [[UserAccount alloc] init];
//    
//    newAccount.username = username;
//    newAccount.secretData = data;
//    newAccount.authType = TwitterAuthOAuth;
//    
//    // Notification parameters
//    NSDictionary *loginData = [NSDictionary dictionaryWithObjectsAndKeys: newAccount, kNewAccountLoginDataKey, _currentAccount, kOldAccountLoginDataKey, nil];
//    [newAccount release];
//    
//    // Post LoginControllerAccountDidChange notifiaction
//    [[NSNotificationCenter defaultCenter] postNotificationName: (NSString *)LoginControllerAccountDidChange 
//                                                        object: nil
//                                                      userInfo: loginData];
//    [self.navigationController popViewControllerAnimated:YES];
//    oAuthAuthorization = YES;
//}

//- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username 
//{
//    if (_currentAccount)
//        return [_currentAccount secretData];
//    return nil;
//}

//#pragma mark MGTwitterEngine delegate methods
//- (void)requestSucceeded:(NSString *)connectionIdentifier
//{
//    if ([connectionIdentifier isEqualToString:twitterUserCredentialID])
//        [self processAccountInfo];
//    twitterUserCredentialID = nil;
//    [twitter autorelease];
//    twitter = nil;
////    [progress hide];
////    [progress release];
////    self.navigationItem.rightBarButtonItem.enabled = YES;
////    self.navigationItem.leftBarButtonItem.enabled = YES;
////    [authTypeSegment setEnabled:YES forSegmentAtIndex:0];
////    [authTypeSegment setEnabled:YES forSegmentAtIndex:1];
//}
//
//- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
//{
////    [progress hide];
////    [progress release];
//	
//	UIAlertView *theAlert = CreateAlertWithError(error);
//    [theAlert show];
//    [theAlert release];
//    twitterUserCredentialID = nil;
//    [twitter autorelease];
//    twitter = nil;
////    self.navigationItem.rightBarButtonItem.enabled = YES;
////    self.navigationItem.leftBarButtonItem.enabled = YES;
////    [authTypeSegment setEnabled:YES forSegmentAtIndex:0];
////    [authTypeSegment setEnabled:YES forSegmentAtIndex:1];
//}
//




#pragma mark -
#pragma mark Actions

- (IBAction)xAuthAccessTokenRequestButtonTouchUpInside
{
    self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
    //    SA_OAuthTwitterEngine *engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
    self.twitterEngine.consumerKey = kTweeteroConsumerKey;
    self.twitterEngine.consumerSecret = kTweeteroConsumerSecret;
    
	NSString *username = usernameTextField.text;
	NSString *password = passwordTextField.text;
	
	NSLog(@"About to request an xAuth token exchange for username: ]%@[ password: ]%@[.", username, password);
	
    NSLog(@"twitter engine: %@", self.twitterEngine);
	[self.twitterEngine exchangeAccessTokenForUsername:username password:password];
}

- (IBAction)sendTestTweetButtonTouchUpInside
{
	NSString *tweetText = @"Sorry for the testing spam...";
	NSLog(@"About to send test tweet: \"%@\"", tweetText);
	[self.twitterEngine sendUpdate:tweetText];
}

#pragma mark -
#pragma mark XAuthTwitterEngineDelegate methods

- (void) storeCachedTwitterXAuthAccessTokenString: (NSString *)tokenString forUsername:(NSString *)username
{
	//
	// Note: do not use NSUserDefaults to store this in a production environment. 
	// ===== Use the keychain instead. Check out SFHFKeychainUtils if you want 
	//       an easy to use library. (http://github.com/ldandersen/scifihifi-iphone) 
	//
	NSLog(@"Access token string returned: %@", tokenString);
	
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
	
	// Enable the send tweet button.
	self.sendTweetButton.enabled = YES;
}

- (NSString *) cachedTwitterXAuthAccessTokenStringForUsername: (NSString *)username;
{
	NSString *accessTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedXAuthAccessTokenStringKey];
	
	NSLog(@"About to return access token string: %@", accessTokenString);
	
	return accessTokenString;
}


- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error;
{
	NSLog(@"Error: %@", error);
	
	UIAlertViewQuick(@"Authentication error", @"Please check your username and password and try again.", @"OK");
}


#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Twitter request succeeded: %@", connectionIdentifier);
	
	UIAlertViewQuick(@"Tweet sent!", @"The tweet was successfully sent. Everything works!", @"OK");
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
    
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				UIAlertViewQuick(@"Oops!", @"Your username and password could not be verified. Double check that you entered them correctly and try again.", @"OK");	
				break;				
			}
				
			case 502:
			{
				// Bad gateway: twitter is down or being upgraded.
				UIAlertViewQuick(@"Fail whale!", @"Looks like Twitter is down or being updated. Please wait a few seconds and try again.", @"OK");	
				break;				
			}
				
			case 503:
			{
				// Service unavailable
				UIAlertViewQuick(@"Hold your taps!", @"Looks like Twitter is overloaded. Please wait a few seconds and try again.", @"OK");	
				break;								
			}
				
			default:
			{
				NSString *errorMessage = [[NSString alloc] initWithFormat: @"%d %@", [error	code], [error localizedDescription]];
				UIAlertViewQuick(@"Twitter error!", errorMessage, @"OK");	
				[errorMessage release];
				break;				
			}
		}
		
	}
	else 
	{
		switch ([error code]) {
				
			case -1009:
			{
				UIAlertViewQuick(@"You're offline!", @"Sorry, it looks like you lost your Internet connection. Please reconnect and try again.", @"OK");					
				break;				
			}
				
			case -1200:
			{
				UIAlertViewQuick(@"Secure connection failed", @"I couldn't connect to Twitter. This is most likely a temporary issue, please try again.", @"OK");					
				break;								
			}
				
			default:
			{				
				NSString *errorMessage = [[NSString alloc] initWithFormat:@"%@ xx %d: %@", [error domain], [error code], [error localizedDescription]];
				UIAlertViewQuick(@"Network Error!", errorMessage , @"OK");
				[errorMessage release];
			}
		}
	}
	
}


@end
