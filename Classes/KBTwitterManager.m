//
//  KBTwitterManager.m
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterManager.h"
#import "UIAlertView+Helper.h"
#import "KBAccountManager.h"

#define NUM_TWEETS_TO_CACHE 25

static KBTwitterManager *sharedInstance = nil;

@implementation KBTwitterManager

@synthesize delegate;
@synthesize twitterEngine;
@synthesize theSearchResults;
@synthesize searchTerm;

+ (KBTwitterManager*) twitterManager
{
    @synchronized(self)
    {
        if (sharedInstance == nil){
			sharedInstance = [[KBTwitterManager alloc] init];
		}
	}
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
    DLog(@"twittermanager release called");
    //[super release];
}

- (id)autorelease {
  DLog(@"twittermanager autorelease called");
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (XAuthTwitterEngine*) twitterEngine {
    if (!twitterEngine) {
        twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
        twitterEngine.consumerKey = kOAuthConsumerKey;
        twitterEngine.consumerSecret = kOAuthConsumerSecret;
    }
    return twitterEngine;
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
	if (![tokenString isEqualToString:@""]) {
		[[KBAccountManager sharedInstance] setUsesTwitter:YES];
		
		// Enable the send tweet button.
		//self.sendTweetButton.enabled = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completedTwitterLogin" object:nil];
		
	}
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
	
	UIAlertViewQuick(@"Authentication error", @"Please check your username and password and try again.", @"OK");
}


- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	DLog(@"Twitter request succeeded 5: %@", connectionIdentifier);
	
	//UIAlertViewQuick(@"twitter call worked!", @"Everything works!", @"OK");
}

//- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
//{
//	DLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
//    
//}

// These delegate methods shoot off a Notification because the TwitterManager owns the twitterEngine.
// There needs to be a better way to do this.
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    DLog(@"Receive status");
    if([(NSObject*)delegate respondsToSelector:@selector(statusesReceived:)]){
    	[delegate statusesReceived:statuses]; //if it doesn't respond, there was a network error
    } else DLog(@"unable to call statusesReceived with info %@ ----------------------------------------------- for controller %@", statuses, delegate);
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
  if ([(NSObject*)delegate respondsToSelector:@selector(directMessagesReceived:)])
  	[delegate directMessagesReceived:messages];
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
  if ([(NSObject*)delegate respondsToSelector:@selector(userInfoReceived:)])
	[delegate userInfoReceived:userInfo];
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
  if ([(NSObject*)delegate respondsToSelector:@selector(miscInfoReceived:)])
    [delegate miscInfoReceived:miscInfo];
}

- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier; {
  if ([(NSObject*)delegate respondsToSelector:@selector(searchResultsReceived:)])
    [delegate searchResultsReceived:searchResults];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	DLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
    
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				UIAlertViewQuick(@"Oops!", @"This person has protected their tweets.  You need to send a request before you can start following this person.", @"OK");	
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

// only cache a certain number of tweets. if you don't, you'll get an ever-increasing number of tweets cached
- (void) cacheStatusArray:(NSArray*)statuses withKey:(NSString*)key {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:[statuses subarrayWithRange:((NSRange){0, [statuses count] < 25 ? [statuses count] : 25})]];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:key];
    DLog(@"statuses stored!");
}

- (NSArray*) retrieveCachedStatusArrayWithKey:(NSString*)key {
    NSData *statusArrayData = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    DLog(@"retrieving statuses!");
    return [NSKeyedUnarchiver unarchiveObjectWithData:statusArrayData];
}

- (BOOL) hasGeoTweetTurnedOn {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kKBTwitterGeoTweetKey] boolValue];
}

- (void) setHasGeoTweetTurnedOn:(BOOL)hasGeoTweet {
    [[NSUserDefaults standardUserDefaults] setObject:hasGeoTweet forKey:kKBTwitterGeoTweetKey];
}


@end
