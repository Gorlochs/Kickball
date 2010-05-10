//
//  KBTwitterManager.m
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterManager.h"
#import "UIAlertView+Helper.h"

#define NUM_TWEETS_TO_CACHE 25

static KBTwitterManager *sharedInstance = nil;

@implementation KBTwitterManager

@synthesize twitterEngine;
@synthesize searchResults, searchTerm;

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
}

- (id)autorelease {
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
	NSLog(@"Access token string returned: %@", tokenString);
	
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
	
	// Enable the send tweet button.
	//self.sendTweetButton.enabled = YES;
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


- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Twitter request succeeded: %@", connectionIdentifier);
	
	//UIAlertViewQuick(@"twitter call worked!", @"Everything works!", @"OK");
}

//- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
//{
//	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
//    
//}

// These delegate methods shoot off a Notification because the TwitterManager owns the twitterEngine.
// There needs to be a better way to do this.
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
    NSLog(@"Receive status");
    //NSLog(@"%@", statuses);
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:statuses, nil] forKeys:[NSArray arrayWithObjects:@"statuses", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwitterStatusRetrievedNotificationKey
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:messages, nil] forKeys:[NSArray arrayWithObjects:@"statuses", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwitterDMRetrievedNotificationKey
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
    //NSLog(@"************* userinfo: %@", userInfo);
    NSDictionary *ui = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:userInfo, nil] forKeys:[NSArray arrayWithObjects:@"userInfo", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwitterUserInfoRetrievedNotificationKey
                                                        object:nil
                                                      userInfo:ui];
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:miscInfo, nil] forKeys:[NSArray arrayWithObjects:@"miscInfo", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwitterMiscRetrievedNotificationKey
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier; {
    
    NSLog(@"search results: %@", searchResults);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:searchResults, nil] forKeys:[NSArray arrayWithObjects:@"searchResults", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwitterSearchRetrievedNotificationKey
                                                        object:nil
                                                      userInfo:userInfo];
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

// only cache a certain number of tweets. if you don't, you'll get an ever-increasing number of tweets cached
- (void) cacheStatusArray:(NSArray*)statuses withKey:(NSString*)key {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:[statuses subarrayWithRange:((NSRange){0, [statuses count] < 25 ? [statuses count] : 25})]];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:key];
    NSLog(@"statuses stored!");
}

- (NSArray*) retrieveCachedStatusArrayWithKey:(NSString*)key {
    NSData *statusArrayData = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    NSLog(@"retrieving statuses!");
    return [NSKeyedUnarchiver unarchiveObjectWithData:statusArrayData];
}

- (BOOL) hasGeoTweetTurnedOn {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kKBTwitterGeoTweetKey] boolValue];
}

- (void) setHasGeoTweetTurnedOn:(BOOL)hasGeoTweet {
    [[NSUserDefaults standardUserDefaults] setObject:hasGeoTweet forKey:kKBTwitterGeoTweetKey];
}


@end
