//
//  KBTwitterManager.m
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterManager.h"
#import "UIAlertView+Helper.h"


static KBTwitterManager *sharedInstance = nil;

@implementation KBTwitterManager

@synthesize twitterEngine;

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

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
    
}

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
    
    NSDictionary *ui = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[userInfo objectAtIndex:0], nil] forKeys:[NSArray arrayWithObjects:@"userInfo", nil]];
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


- (void) cacheStatusArray:(NSArray*)statuses withKey:(NSString*)key {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:statuses];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:key];
    NSLog(@"statuses stored!");
}

- (NSArray*) retrieveCachedStatusArrayWithKey:(NSString*)key {
    NSData *statusArrayData = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    NSLog(@"retrieving statuses!");
    return [NSKeyedUnarchiver unarchiveObjectWithData:statusArrayData];
}


@end
