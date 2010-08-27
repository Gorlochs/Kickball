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
#import "KBBaseViewController.h"

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
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
	[theSearchResults release];
	[searchTerm release];
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
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"twittername"]; //store the username
	//
	// Note: do not use NSUserDefaults to store this in a production environment. 
	// ===== Use the keychain instead. Check out SFHFKeychainUtils if you want 
	//       an easy to use library. (http://github.com/ldandersen/scifihifi-iphone) 
	//
	DLog(@"Access token string returned: %@", tokenString);
	
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
    } else {
		DLog(@"unable to call statusesReceived with info %@ ----------------------------------------------- for controller %@", statuses, delegate);
	}
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
	if ([(NSObject*)delegate respondsToSelector:@selector(directMessagesReceived:)]) {
		[delegate directMessagesReceived:messages];
	}
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	if ([(NSObject*)delegate respondsToSelector:@selector(userInfoReceived:)]){
		[delegate userInfoReceived:userInfo];
	}else {
		NSDictionary *userDictionary = [userInfo objectAtIndex:0];
		if (userDictionary) {
			NSString *profileImage = [userDictionary objectForKey:@"profile_image_url"];
			if (profileImage) {
				NSString *screenName = [userDictionary objectForKey:@"screen_name"];
				NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"];
				if (screenName && username && [screenName isEqualToString:username]) { //only use the profile pic for the user!!
					[[NSUserDefaults standardUserDefaults] setObject:profileImage forKey:@"twitUserPhotoURL"];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
			}
		}
	}
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
	if ([(NSObject*)delegate respondsToSelector:@selector(miscInfoReceived:)])
		[delegate miscInfoReceived:miscInfo];
}

- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier; {
	if ([(NSObject*)delegate respondsToSelector:@selector(searchResultsReceived:)])
		[delegate searchResultsReceived:searchResults];
}

- (void)stopProgressBar {
	[(KBBaseViewController*)delegate stopProgressBar];
}

- (void)delayedViewLoadFailure { //wait for the animation to finish loading the new view, or we will actually go back two pages instead of one
	[[NSNotificationCenter defaultCenter] postNotificationName:@"twitterViewLoadFailure" object:nil];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	DLog(@"actual Twitter request failed 2: %@ with error:%@", connectionIdentifier, error);
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				UIAlertViewQuick(@"Oops!", @"This person has protected their tweets.  You need to send a request before you can start following this person.", @"OK");	
				[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(delayedViewLoadFailure) userInfo:nil repeats:NO];
				break;				
			}
				
			case 404:
			{
				// Page doesn't exist. e.g., a nonexistant username was searched on
				UIAlertViewQuick(@"Page Does Not Exist", @"The Twitter information that you are looking for does not exist.", @"OK");	
				[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(delayedViewLoadFailure) userInfo:nil repeats:NO];
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
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(stopProgressBar) userInfo:nil repeats:NO];
	
}

// only cache a certain number of tweets. if you don't, you'll get an ever-increasing number of tweets cached
- (void) cacheStatusArray:(NSArray*)statuses withKey:(NSString*)key {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:[statuses subarrayWithRange:((NSRange){0, [statuses count] < 25 ? [statuses count] : 25})]];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearCaches {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKBTwitterTimelineKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKBTwitterMentionsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKBTwitterDirectMessagesKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"twittername"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"twitUserPhotoURL"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*) retrieveCachedStatusArrayWithKey:(NSString*)key {
    DLog(@"retrieving statuses!");
    NSData *statusArrayData = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:statusArrayData];
}

- (BOOL) hasGeoTweetTurnedOn {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kKBTwitterGeoTweetKey] boolValue];
}

- (void) setHasGeoTweetTurnedOn:(BOOL)hasGeoTweet {
    [[NSUserDefaults standardUserDefaults] setObject:hasGeoTweet forKey:kKBTwitterGeoTweetKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
