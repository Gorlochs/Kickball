//
//  KBTwitterLoginView.m
//  Kickball
//
//  Created by scott bates on 6/22/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBTwitterLoginView.h"
#import "KBTwitterManager.h"
#import "XAuthTwitterEngine.h"
#import "UIAlertView+Helper.h"
#import "KBAccountManager.h"
#import "KBBaseTweetViewController.h"
@implementation KBTwitterLoginView
@synthesize twitterEngine;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField==userName) {
		[userName resignFirstResponder];
		[password becomeFirstResponder];
	}else {
		[password resignFirstResponder];
		[(KBBaseViewController*)delegate startProgressBar:@"Logging in..."];
		NSString *un = userName.text;
		NSString *pw = password.text;
		
		DLog(@"About to request an xAuth token exchange for username: ]%@[ password: ]%@[.", un, pw);
		if (self.twitterEngine==nil) {
			self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
			self.twitterEngine.consumerKey = kOAuthConsumerKey;
			self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
		}
		[self.twitterEngine exchangeAccessTokenForUsername:un password:pw];
		//store the username so we can get their profile pic later
		[[NSUserDefaults standardUserDefaults] setObject:un forKey:@"twittername"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	}
	
    //[self cancelEditing];
    return NO;
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
	DLog(@"Access token string returned: %@", tokenString);
	
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginNotification"
                                                        object:nil
                                                      userInfo:nil];
    [[KBAccountManager sharedInstance] setUsesTwitter:YES];
	//	twitterEngine = nil;
	//	[twitterEngine release];
	//    twitterEngine = [[KBTwitterManager twitterManager] twitterEngine];
	if([delegate respondsToSelector:@selector(showStatuses)]){
		[(KBBaseTweetViewController*)delegate showStatuses];
	}
	[delegate killLoginView];
	[delegate stopProgressBar];
    //[self dismissModalViewControllerAnimated:YES];
}

- (NSString *) cachedTwitterXAuthAccessTokenStringForUsername: (NSString *)username;
{
	NSString *accessTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedXAuthAccessTokenStringKey];
	
	DLog(@"About to return access token string: %@", accessTokenString);
	
	return accessTokenString;
}


- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error;
{
	DLog(@"Error: %@", error);
	[(KBBaseViewController*)delegate stopProgressBar];
	UIAlertViewQuick(@"Authentication error", @"Please check your username and password and try again.", @"OK");
}


#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	DLog(@"Twitter request succeeded 6: %@", connectionIdentifier);
	
	UIAlertViewQuick(@"Tweet sent!", @"The tweet was successfully sent. Everything works!", @"OK");
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	DLog(@"Twitter request failed 6: %@ with error:%@", connectionIdentifier, error);
	[(KBBaseViewController*)delegate stopProgressBar];
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				UIAlertViewQuick(@"Oops!", @"Your username and password could not be verified. Double check that you entered them correctly and try again.", @"OK");	
				break;				
			}
				
			case 404:
			{
				// Page doesn't exist. e.g., a nonexistant username was searched on
				UIAlertViewQuick(@"Page Does Not Exist", @"The Twitter information that you are looking for does not exist.", @"OK");	
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


- (void)dealloc {
	[twitterEngine release];
    [super dealloc];
}


@end
