//
//  FoursquareAPI.m
//  FSApi
//
//  Created by David Evans on 11/1/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FoursquareAPI.h"
#import "Utilities.h"
#import "FSMayor.h"
#import "FSSpecial.h"
#import "SFHFKeychainUtils.h"

#define USER_AGENT @"UltraDudez:0.0.1"

static FoursquareAPI *sharedInstance = nil;

@implementation FoursquareAPI

@synthesize oauthAPI, currentUser, userName, passWord, activeRequests;

#pragma mark -
#pragma mark class instance methods

#pragma mark -
#pragma mark Singleton methods

+ (FoursquareAPI*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil){
			sharedInstance = [[FoursquareAPI alloc] init];
//			NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	kConsumerKey, kMPOAuthCredentialConsumerKey,
//										 kConsumerSecret, kMPOAuthCredentialConsumerSecret,
//										 nil];
//			
//			
//			sharedInstance.oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
//								  authenticationURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/authexchange"]
//														 andBaseURL:[NSURL URLWithString:@"http://api.foursquare.com"]];
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

- (void)doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass{
	
	self.userName = fsUser; 
	self.passWord = fsPass;
	
//	NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	kConsumerKey, kMPOAuthCredentialConsumerKey,
//								 kConsumerSecret, kMPOAuthCredentialConsumerSecret,
//								 nil];
//	
//	self.oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
//									  authenticationURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/authexchange"]
//											 andBaseURL:[NSURL URLWithString:@"http://api.foursquare.com"]
//											 fsUsername:fsUser
//											 fsPassword:fsPass];
//	self.oauthAPI.delegate = (id <MPOAuthAPIDelegate>)[UIApplication sharedApplication].delegate;
//    MPOAuthCredentialConcreteStore *credStore = [self.oauthAPI credentials];
//    NSLog(@"cred: %@", [credStore oauthParameters]);
////    NSLog(@"cred time: %@", [self.oauthAPI credentials].timestamp);
////    NSLog(@"cred request token: %@", [self.oauthAPI credentials].requestToken);
////    NSLog(@"cred consumer key: %@", [self.oauthAPI credentials].consumerKey);
//    NSLog(@"auth state: %@", self.oauthAPI.authenticationState);
}

- (BOOL) isAuthenticated{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //TODO: use a constant
    self.userName = [prefs objectForKey:@"FSUsername"];
    if (self.userName) {
        NSError *error = nil;
        self.passWord = [SFHFKeychainUtils getPasswordForUsername:self.userName andServiceName:@"Kickball" error:&error];
        return YES;
    } else {
		return NO;
	}
//	
//	NSString *accessTokenSecret = [self.oauthAPI findValueFromKeychainUsingName:@"oauth_token_access_secret"];
//    //NSLog(@"****** accessTokenSecret: %@", accessTokenSecret);
//	if(accessTokenSecret != nil){
//		return YES;
//	} else return NO;
}


- (void)getVenuesNearLatitude: (NSString *)geolat andLongitude:(NSString *) geolong withTarget:(id)inTarget andAction:(SEL)inAction{
//	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//	
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolat" andValue:geolat]];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolong" andValue:geolong]];
//	//[params addObject:[[MPURLRequestParameter alloc] initWithName:@"l" andValue:@"100"]];  // seems that there is a limit of 50 veunes returned
//	
//	[self.oauthAPI performMethod:@"/v1/venues" withTarget:inTarget withParameters:params  andAction:inAction];
	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:3];
    
    // TODO: maybe make the num returned (l) a parameter?
	[requestParams setObject:geolat forKey:@"geolat"];
	[requestParams setObject:geolong forKey:@"geolong"];
	[requestParams setObject:@"20" forKey:@"l"]; 
	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/venues"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];

}

// this might could be combined with the above method
- (void)getVenuesByKeyword: (NSString *)geolat andLongitude:(NSString *) geolong andKeywords:(NSString *) keywords withTarget:(id)inTarget andAction:(SEL)inAction{
//	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//	
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolat" andValue:geolat]];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolong" andValue:geolong]];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"q" andValue:[keywords stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
//	
//	[self.oauthAPI performMethod:@"/v1/venues" withTarget:inTarget withParameters:params  andAction:inAction];
	
	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:3];
	
	[requestParams setObject:geolat forKey:@"geolat"];
	[requestParams setObject:geolong forKey:@"geolong"];
	[requestParams setObject:[keywords stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:@"q"];
	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/venues"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];

}

- (void)getVenue:(NSString *)venueId withTarget:(id)inTarget andAction:(SEL)inAction{
//	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"vid" andValue:venueId]];
//	[self.oauthAPI performMethod:@"/v1/venue" withTarget:inTarget withParameters:params  andAction:inAction];
	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:venueId forKey:@"vid"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/venue"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];

}

- (void)getUser:(NSString *)userId withTarget:(id)inTarget andAction:(SEL)inAction{
//	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"uid" andValue:userId]];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"badges" andValue:@"1"]];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"mayor" andValue:@"1"]];
//	[self.oauthAPI performMethod:@"/v1/user" withTarget:inTarget withParameters:params  andAction:inAction];

	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:3];
	if(userId != nil){
		[requestParams setObject:userId forKey:@"uid"];
	}
	[requestParams setObject:@"1" forKey:@"badges"];
	[requestParams setObject:@"1" forKey:@"mayor"];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/user"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void)getCheckinsWithTarget:(id)inTarget andAction:(SEL)inAction{
	//	[self.oauthAPI performMethod:@"/v1/checkins" withTarget:inTarget andAction:inAction];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/checkins"] withUser:self.userName andPassword:self.passWord andParams:nil withTarget:inTarget andAction:inAction usingMethod:@"GET"];

}

- (void)getFriendsWithTarget:(id)inTarget andAction:(SEL)inAction{
	//[self.oauthAPI performMethod:@"/v1/friends" withTarget:inTarget andAction:inAction];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/friends"] withUser:self.userName andPassword:self.passWord andParams:nil withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void)getFriendsWithUserIdAndTarget:(NSString*)userId andTarget:(id)inTarget andAction:(SEL)inAction {
	//[self.oauthAPI performMethod:@"/v1/friends" withTarget:inTarget andAction:inAction];
	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:userId forKey:@"uid"];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/friends"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

// using this to authenticate against the API since Foursquare does not have simple authentication methods
- (void)getFriendsWithTarget:(NSString*)username andPassword:(NSString*)password andTarget:(id)inTarget andAction:(SEL)inAction {
	//[self.oauthAPI performMethod:@"/v1/friends" withTarget:inTarget andAction:inAction];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/friends"] withUser:username andPassword:password andParams:nil withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void)getUserWithTarget:(id)inTarget andAction:(SEL)inAction{
//	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//	
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"badges" andValue:@"1"]];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"mayor" andValue:@"1"]];
//	[self.oauthAPI performMethod:@"/v1/user" withTarget:inTarget withParameters:params andAction:inAction];
	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:3];
	[requestParams setObject:@"1" forKey:@"badges"];	
	[requestParams setObject:@"1" forKey:@"mayor"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/user"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];

}

- (void)getCityNearestToLatitude:(NSString *) geolat andLongitude:(NSString *)geolong withTarget:(id)inTarget andAction:(SEL)inAction{
//	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//	
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolat" andValue:geolat]];
//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolong" andValue:geolong]];
//	[self.oauthAPI performMethod:@"/v1/checkcity" withTarget:inTarget withParameters:params andAction:inAction];
	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:3];
	[requestParams setObject:geolat forKey:@"geolat"];	
	[requestParams setObject:geolong forKey:@"geolong"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/checkcity"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void)setPings:(NSString*)pingStatus forUser:(NSString *)userId withTarget:(id)inTarget andAction:(SEL)inAction {
    NSLog(@"setting ping status (%@) for user: %@", pingStatus, userId);
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:pingStatus forKey:userId];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/settings/setpings"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];
}

- (void) doVenuelessCheckin:(NSString*)venueName withTarget:(id)inTarget andAction:(SEL)inAction {
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
    
	[requestParams setObject:venueName forKey:@"venue"];
    [self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/checkin"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];
}

- (void) doCheckinAtVenueWithId:(NSString *)venueId andShout:(NSString *)shout offGrid:(BOOL)offGrid toTwitter:(BOOL)toTwitter withTarget:(id)inTarget andAction:(SEL)inAction {
//	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
	NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:3];

//	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"vid" andValue:venueId]];

    if (venueId) {
        [requestParams setObject:venueId forKey:@"vid"];	
    }
	if(shout){
		[requestParams setObject:shout forKey:@"shout"];	
//		[params addObject:[[MPURLRequestParameter alloc] initWithName:@"shout" andValue:shout]];
	}
	if(offGrid == YES){
		[requestParams setObject:@"1" forKey:@"private"];	
//		[params addObject:[[MPURLRequestParameter alloc] initWithName:@"private" andValue:@"1"]];
	} else {
		[requestParams setObject:@"0" forKey:@"private"];	
//		[params addObject:[[MPURLRequestParameter alloc] initWithName:@"private" andValue:@"0"]];
	}
	if(toTwitter == YES){
		[requestParams setObject:@"1" forKey:@"twitter"];	
//		[params addObject:[[MPURLRequestParameter alloc] initWithName:@"twitter" andValue:@"1"]];
	} else {
		[requestParams setObject:@"0" forKey:@"twitter"];	
//		[params addObject:[[MPURLRequestParameter alloc] initWithName:@"twitter" andValue:@"0"]];
	}
	NSLog(@"checkin params: %@", requestParams);
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/checkin"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];
//    [self.oauthAPI performMethod:@"/v1/checkin" withTarget:inTarget withParameters:params andAction:inAction doPost:YES];
}

- (void) doSendFriendRequest:(NSString*)userId withTarget:(id)inTarget andAction:(SEL)inAction {
//    NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//    [params addObject:[[MPURLRequestParameter alloc] initWithName:@"uid" andValue:userId]];
//    [self.oauthAPI performMethod:@"/v1/friend/sendrequest" withTarget:inTarget withParameters:params andAction:inAction doPost:YES];
    
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:userId forKey:@"uid"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/friend/sendrequest"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];
}

- (void) approveFriendRequest:(NSString*)userId withTarget:(id)inTarget andAction:(SEL)inAction {
//    NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//    [params addObject:[[MPURLRequestParameter alloc] initWithName:@"uid" andValue:userId]];
//    [self.oauthAPI performMethod:@"/v1/friend/approve" withTarget:inTarget withParameters:params andAction:inAction doPost:YES];
    
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:userId forKey:@"uid"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/friend/approve"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];    
}

- (void) denyFriendRequest:(NSString*)userId withTarget:(id)inTarget andAction:(SEL)inAction {
//    NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//    [params addObject:[[MPURLRequestParameter alloc] initWithName:@"uid" andValue:userId]];
//    [self.oauthAPI performMethod:@"/v1/friend/deny" withTarget:inTarget withParameters:params andAction:inAction doPost:YES];
    
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:userId forKey:@"uid"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/friend/deny"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];
}

- (void) findFriendsByName:(NSString*)name withTarget:(id)inTarget andAction:(SEL)inAction {
//    NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//    [params addObject:[[MPURLRequestParameter alloc] initWithName:@"q" andValue:name]];
//    [self.oauthAPI performMethod:@"/v1/findfriends/byname" withTarget:inTarget withParameters:params andAction:inAction doPost:NO];
    
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:name forKey:@"q"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/findfriends/byname"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void) findFriendsByPhone:(NSString*)phone withTarget:(id)inTarget andAction:(SEL)inAction {
//    NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//    [params addObject:[[MPURLRequestParameter alloc] initWithName:@"q" andValue:phone]];
//    [self.oauthAPI performMethod:@"/v1/findfriends/byphone" withTarget:inTarget withParameters:params andAction:inAction doPost:NO];
    
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:phone forKey:@"q"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/findfriends/byphone"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void) findFriendsByTwitterName:(NSString*)twitterName withTarget:(id)inTarget andAction:(SEL)inAction {
//    NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
//    [params addObject:[[MPURLRequestParameter alloc] initWithName:@"q" andValue:twitterName]];
//    [self.oauthAPI performMethod:@"/v1/findfriends/bytwitter" withTarget:inTarget withParameters:params andAction:inAction doPost:NO];
    
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:twitterName forKey:@"q"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/findfriends/bytwitter"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void) getPendingFriendRequests:(id)inTarget andAction:(SEL)inAction {
//    [self.oauthAPI performMethod:@"/v1/friend/requests" withTarget:inTarget andAction:inAction doPost:NO];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/friend/requests"] withUser:self.userName andPassword:self.passWord andParams:nil withTarget:inTarget andAction:inAction usingMethod:@"GET"];
}

- (void) addNewVenue:(NSString*)name atAddress:(NSString*)address andCrossstreet:(NSString*)crossStreet andCity:(NSString*)city andState:(NSString*)state  
          andOptionalZip:(NSString*)zip andRequiredCityId:(NSString*)cityId andOptionalPhone:(NSString*)phone  withTarget:(id)inTarget andAction:(SEL)inAction {  
    
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:8];
	[requestParams setObject:name forKey:@"name"];
	[requestParams setObject:address forKey:@"address"];
	[requestParams setObject:crossStreet forKey:@"crossstreet"];
	[requestParams setObject:city forKey:@"city"];
	[requestParams setObject:state forKey:@"state"];
	[requestParams setObject:zip forKey:@"zip"];
	[requestParams setObject:cityId forKey:@"cityId"];
	[requestParams setObject:phone forKey:@"phone"];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/addvenue"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];
}

- (void) flagVenueAsClosed:(NSString*)venueId withTarget:(id)inTarget andAction:(SEL)inAction {
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:venueId forKey:@"vid"];	
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/venue/flagclosed"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];
}

- (void) createTipTodoForVenue:(NSString*)venueId type:(NSString*)tipOrTodo text:(NSString*)tipTodoText withTarget:(id)inTarget andAction:(SEL)inAction {
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:venueId forKey:@"vid"];
	[requestParams setObject:tipTodoText forKey:@"text"];
	[requestParams setObject:tipOrTodo forKey:@"type"];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/addtip"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];    
}

- (void) markTipAsTodo:(NSString*)tipId withTarget:(id)inTarget andAction:(SEL)inAction {
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:tipId forKey:@"tid"];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/tip/marktodo"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];    
}

- (void) markTipAsDone:(NSString*)tipId withTarget:(id)inTarget andAction:(SEL)inAction {
    NSMutableDictionary * requestParams =[[NSMutableDictionary alloc] initWithCapacity:1];
	[requestParams setObject:tipId forKey:@"tid"];
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/tip/markdone"] withUser:self.userName andPassword:self.passWord andParams:requestParams withTarget:inTarget andAction:inAction usingMethod:@"POST"];    
}

- (void) doFoursquareApiTest:(id)inTarget andAction:(SEL)inAction {
	[self loadBasicAuthURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/test"] withUser:nil andPassword:nil andParams:nil withTarget:inTarget andAction:inAction usingMethod:@"GET"];    
}

#pragma mark
#pragma mark response parsers

+ (NSArray *) friendRequestsFromResponseXML:(NSString *) inString {
	
	NSError * err = nil;
	CXMLDocument *userParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"error: %@", [err localizedDescription]);
	
	NSArray * allUsers;
    NSMutableArray * users = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
	
	//get the groups
	allUsers = [userParser nodesForXPath:@"//requests/user" error:nil];
    NSLog(@"allusers: %@", allUsers);
	for (CXMLElement *userResult in allUsers) {
        [users addObject:[FoursquareAPI _userFromNode:userResult]];
	}
    [userParser release];
	return users;
}

+ (NSString*) tipIdFromResponseXML:(NSString *) inString {
	NSError * err = nil;
	CXMLDocument *settingsParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"error: %@", [err localizedDescription]);
    
    NSString *tipId = nil;
    NSArray *settings = [settingsParser nodesForXPath:@"//tip" error:&err];
    for (CXMLElement *settingsResult in settings) {
		for(int counter = 0; counter < [settingsResult childCount]; counter++) {
			NSString * key = [[settingsResult childAtIndex:counter] name];
			NSString * value = [[settingsResult childAtIndex:counter] stringValue];
            if([key isEqualToString:@"id"]){
				tipId = value;
            }
        }
    }
    [settingsParser release];
    return tipId;
}

+ (BOOL) simpleBooleanFromResponseXML:(NSString *) inString {
	NSError * err = nil;
	CXMLDocument *settingsParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"error: %@", [err localizedDescription]);
    
    BOOL isOK = NO;
    NSArray *settings = [settingsParser nodesForXPath:@"/" error:&err];
    for (CXMLElement *settingsResult in settings) {
		for(int counter = 0; counter < [settingsResult childCount]; counter++) {
			NSString * key = [[settingsResult childAtIndex:counter] name];
			NSString * value = [[settingsResult childAtIndex:counter] stringValue];
            if([key isEqualToString:@"response"]){
				isOK = [value isEqualToString:@"ok"];
            }
        }
    }
    [settingsParser release];
    return isOK;
}

+ (BOOL) pingSettingFromResponseXML:(NSString *) inString {
	NSError * err = nil;
	CXMLDocument *settingsParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"error: %@", [err localizedDescription]);
    
    BOOL isPingSet = NO;
    NSArray *settings = [settingsParser nodesForXPath:@"//settings" error:&err];
    for (CXMLElement *settingsResult in settings) {
		for(int counter = 0; counter < [settingsResult childCount]; counter++) {
			NSString * key = [[settingsResult childAtIndex:counter] name];
			NSString * value = [[settingsResult childAtIndex:counter] stringValue];
            if([key isEqualToString:@"pings"]){
                NSLog(@"isPingSet (FoursquareAPI): %@", value);
				isPingSet = [value isEqualToString:@"on"];
            }
        }
    }
    [settingsParser release];
    return isPingSet;
}

+ (NSArray *) usersFromResponseXML:(NSString *) inString {
	
	NSError * err = nil;
	CXMLDocument *userParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"error: %@", [err localizedDescription]);
	
	NSArray * allUsers;
    NSMutableArray * users = [[NSMutableArray alloc] initWithCapacity:1];
	
	//get the groups
	allUsers = [userParser nodesForXPath:@"//users/user" error:nil];
    NSLog(@"allusers: %@", allUsers);
	for (CXMLElement *userResult in allUsers) {
        [users addObject:[FoursquareAPI _userFromNode:userResult]];
	}
    [userParser release];
	return users;
}

+ (NSArray *) usersFromRequestResponseXML:(NSString *) inString {
	
	NSError * err = nil;
	CXMLDocument *userParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"error: %@", [err localizedDescription]);
	
	NSArray * allUsers;
    NSMutableArray * users = [[NSMutableArray alloc] initWithCapacity:1];
	
	//get the groups
	allUsers = [userParser nodesForXPath:@"//requests/user" error:nil];
    NSLog(@"allusers: %@", allUsers);
	for (CXMLElement *userResult in allUsers) {
        [users addObject:[FoursquareAPI _userFromNode:userResult]];
	}
    [userParser release];
	return users;
}

+ (NSArray *) friendUsersFromRequestResponseXML:(NSString *) inString {
	
	NSError * err = nil;
	CXMLDocument *userParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"error: %@", [err localizedDescription]);
	
	NSArray * allUsers;
    NSMutableArray * users = [[NSMutableArray alloc] initWithCapacity:1];
	
	//get the groups
	allUsers = [userParser nodesForXPath:@"//friends/user" error:nil];
    NSLog(@"allusers: %@", allUsers);
	for (CXMLElement *userResult in allUsers) {
        [users addObject:[FoursquareAPI _userFromNode:userResult]];
	}
    [userParser release];
	return users;
}

+ (NSArray *) friendsFromResponseXML:(NSString *) inString{
	
	NSError * err = nil;
	CXMLDocument *friendParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"%@", [err localizedDescription]);
	
	NSArray * allFriends;
	
	//get the groups
	allFriends = [friendParser nodesForXPath:@"//friends/friend" error:nil];
	for (CXMLElement *friendResult in allFriends) {
		allFriends = [[FoursquareAPI _friendsFromNode:friendResult] mutableCopy];
	}
    [friendParser release];
	return allFriends;
}

+ (NSDictionary *) venuesFromResponseXML:(NSString *) inString{

	NSError * err = nil;
	CXMLDocument *venueParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"venues xml: %@", venueParser);
	NSLog(@"error: %@", [err localizedDescription]);

    NSMutableDictionary *allVenues = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	//NSMutableArray * allVens = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];

	NSArray *allGroups = NULL;

	//get the groups
	allGroups = [venueParser nodesForXPath:@"//venues/group" error:nil];
	for (CXMLElement *groupResult in allGroups) {
		NSArray * groupOfVenues = [FoursquareAPI _venuesFromNode:groupResult];
        [allVenues setObject:[groupOfVenues copy] forKey:[[groupResult attributeForName:@"type"] stringValue]];
		//[allVens addObject:[groupOfVenues copy]];
	}
    [venueParser release];
	return allVenues;
}

+ (FSUser *) userFromResponseXML:(NSString *) inString{
	
	NSError * err = nil;
	CXMLDocument *userParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
    NSLog(@"user xml: %@", userParser);
	NSLog(@"%@", [err description]);
	
	NSArray *allUserAttrs = [userParser nodesForXPath:@"user" error:nil];
	for (CXMLElement *usrAttr in allUserAttrs) {
		return [FoursquareAPI _userFromNode:usrAttr];
	}
    [userParser release];
	return nil;
}

+ (FSUser *) loggedInUserFromResponseXML:(NSString *) inString{
	NSError * err;
	CXMLDocument *userParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"%@", [err description]);

	
	NSArray *allUserAttrs = [userParser nodesForXPath:@"user" error:nil];
	for (CXMLElement *usrAttr in allUserAttrs) {
		return [FoursquareAPI _userFromNode:usrAttr];
	}
    [userParser release];
	
	return nil;
}

+ (FSVenue *) venueFromResponseXML:(NSString *) inString{
	
	NSError * err;
	CXMLDocument *venueParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"venue xml: %@", venueParser);
	FSVenue * thisVenue = [[[FSVenue alloc] init] autorelease];
	
	NSArray *allGroups = [venueParser nodesForXPath:@"/" error:nil];
	
	for (CXMLElement *groupResult in allGroups) {
		NSArray * groupOfVenues = [FoursquareAPI _venuesFromNode:groupResult];
        NSLog(@"group of venues: %@", groupOfVenues);
		thisVenue = (FSVenue *)[groupOfVenues objectAtIndex:0];
	}
    [venueParser release];
	return thisVenue;
} 

+ (NSArray *) checkinsFromResponseXML:(NSString *) inString{
	NSError * err;
	CXMLDocument *checkinParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"%@", [err localizedDescription]);
	
	NSLog(@"checkins xml: %@", checkinParser);
    
	NSArray *allCheckinAttrs = [checkinParser nodesForXPath:@"//checkins" error:nil];
    
	for (CXMLElement *checkinAttr in allCheckinAttrs) {
        return [FoursquareAPI _checkinsFromNode:checkinAttr];
    }
    [checkinParser release];
    
    return nil;
}

+ (NSArray *) checkinFromResponseXML:(NSString *) inString{
	NSError * err;
	CXMLDocument *checkinParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"%@", [err localizedDescription]);
	
	NSLog(@"checkins xml: %@", checkinParser);
    
	NSArray *allCheckinAttrs = [checkinParser nodesForXPath:@"//checkin" error:nil];
    
	for (CXMLElement *checkinAttr in allCheckinAttrs) {
        return [FoursquareAPI _checkinsFromNode:checkinAttr];
    }
    [checkinParser release];
    
    return nil;
}

+ (NSArray *) _checkinsFromNode:(CXMLNode *) inputNode {
    NSMutableArray * allCheckins = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    //FSCheckin * oneCheckin = [[FSCheckin alloc] init];
	NSArray * checkinsReturned = [inputNode nodesForXPath:@"//checkin" error:nil];
	for (CXMLElement *checkinAttr in checkinsReturned) {
        FSCheckin * oneCheckin = [[FSCheckin alloc] init];
        //NSLog(@"xml element checkin attr: %@", checkinAttr);
		for (int counter = 0; counter < [checkinAttr childCount]; counter++) {
            NSString * key = [[checkinAttr childAtIndex:counter] name];
            NSString * value = [[checkinAttr childAtIndex:counter] stringValue];
            if([key isEqualToString:@"message"]){
                oneCheckin.message = value;
            } else if([key isEqualToString:@"created"]){
                oneCheckin.created = value;
            } else if([key isEqualToString:@"id"]){
                oneCheckin.checkinId = value;
            } else if([key isEqualToString:@"shout"]){
                oneCheckin.shout = value;
            } else if([key isEqualToString:@"display"]){
                oneCheckin.display = value;
            } else if([key isEqualToString:@"ismayor"]){
                oneCheckin.isMayor = [value isEqualToString:@"true"];
            }
        
            if([key compare:@"user"] == 0){
                NSArray * checkinUser = [checkinAttr elementsForName:@"user"];
                for (CXMLElement *checkedUser in checkinUser) {
                    FSUser * currentUserInfo = [FoursquareAPI _userFromNode:checkedUser];
                    oneCheckin.user = currentUserInfo;
                }
            } else if([key compare:@"venue"] == 0){
                FSVenue * currentVenueInfo = [[FoursquareAPI _venuesFromNode:checkinAttr] objectAtIndex:0];
                oneCheckin.venue = currentVenueInfo;
            } else if ([key compare:@"scoring"] == 0) {
                FSScoring * currentCheckinScoring = [FoursquareAPI _scoringFromNode:checkinAttr];
                oneCheckin.scoring = currentCheckinScoring;
            } else if ([key compare:@"badges"] == 0) {
                NSArray * badgeXML = [checkinAttr nodesForXPath:@"//badges" error:nil];
                if ([badgeXML count] > 0) {
                    oneCheckin.badges = [FoursquareAPI _badgesFromNode:[badgeXML objectAtIndex:0]];
                }
            } else if ([key compare:@"mayor"] == 0) {
                NSArray * mayorNodes = [checkinAttr nodesForXPath:@"//mayor" error:nil];
                FSMayor *checkinMayor = [[FSMayor alloc] init];
                NSArray * mayorUserNodes = [checkinAttr nodesForXPath:@"//mayor/user" error:nil];
                if(mayorUserNodes && [mayorUserNodes count] > 0){
                    checkinMayor.user = [FoursquareAPI _userFromNode:[mayorUserNodes objectAtIndex:0]];
                }
                for (CXMLElement *mayorNode in mayorNodes) {
                    for (int counter = 0; counter < [mayorNode childCount]; counter++) {
                        NSString * key = [[mayorNode childAtIndex:counter] name];
                        NSString * value = [[mayorNode childAtIndex:counter] stringValue];
                        if ([key isEqualToString:@"message"]) {
                            checkinMayor.mayorCheckinMessage = value;
                        } else if ([key isEqualToString:@"checkins"]) {
                            checkinMayor.numCheckins = [value intValue];
                        } else if ([key isEqualToString:@"type"]) {
                            checkinMayor.mayorTransitionType = value;
                        }
                    }
                }
                oneCheckin.mayor = checkinMayor;
                [checkinMayor release];
            } else if ([key compare:@"specials"] == 0) {
                NSArray *specialNodes = [checkinAttr nodesForXPath:@"//specials/special" error:nil];
                NSMutableArray *specialArray = [[NSMutableArray alloc] initWithCapacity:1];
                for (CXMLElement *specialNode in specialNodes) {
                    FSSpecial *special = [[FSSpecial alloc] init];
                    for (int counter = 0; counter < [specialNode childCount]; counter++) {
                        NSString * key = [[specialNode childAtIndex:counter] name];
                        NSString * value = [[specialNode childAtIndex:counter] stringValue];
                        if ([key isEqualToString:@"message"]) {
                            special.message = value;
                        } else if ([key isEqualToString:@"id"]) {
                            special.specialId = value;
                        } else if ([key isEqualToString:@"type"]) {
                            special.type = value;
                        } else if ([key isEqualToString:@"venue"]) {
                            // FIXME: this was done for expediency's sake
//                            NSArray *venueArray = [FoursquareAPI _venuesFromNode:[checkinAttr nodesForXPath:@"//special/venue" error:nil]];
//                            if ([venueArray count] > 0) {
//                                special.venue = [venueArray objectAtIndex:0];
//                            }
                        }
                    }
                    [specialArray addObject:special];
                    [special release];
                }
                oneCheckin.specials = specialArray;
                [specialArray release];
            }
        }
        [allCheckins addObject:oneCheckin];
        [oneCheckin release];
    }
    return allCheckins;
}

+ (FSScoring *) _scoringFromNode:(CXMLNode *) inputNode{
	NSMutableArray * allScores = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
	FSScoring *theScoring = [[[FSScoring alloc] init] autorelease];
	
	//get all the scores in the checkin
	NSArray * scoresReturned = [inputNode nodesForXPath:@"//score" error:nil];
	for (CXMLElement *scoreResult in scoresReturned) {
		FSScore * newScore = [[FSScore alloc] init];
		int counter;
		for(counter = 0; counter < [scoreResult childCount]; counter++) {
			NSString * key = [[scoreResult childAtIndex:counter] name];
			NSString * value = [[scoreResult childAtIndex:counter] stringValue];
			
			if([key isEqualToString:@"points"]){
				newScore.points = [value intValue];
			} else if([key isEqualToString:@"message"]){
				newScore.message = value;
			} else if([key isEqualToString:@"icon"]){
				newScore.icon = value;
			}
		}
		[allScores addObject:newScore];
	}
	theScoring.scores = allScores;
	
	//don't forget to get the total
	NSArray * totalsReturned = [inputNode nodesForXPath:@"total" error:nil];
	for (CXMLElement *totalResult in totalsReturned) {
		int counter;
		for(counter = 0; counter < [totalResult childCount]; counter++) {
			NSString * key = [[totalResult childAtIndex:counter] name];
			NSString * value = [[totalResult childAtIndex:counter] stringValue];
			
			if([key isEqualToString:@"points"]){
				theScoring.total = [value intValue];
			} else if([key isEqualToString:@"message"]){
				theScoring.message = value;
			}
		}
	}
	NSLog(@"the scoring: %@", theScoring);
    [allScores release];
	return theScoring;
}

+ (NSArray *) _venuesFromNode:(CXMLNode *) inputNode{
	NSMutableArray * groupOfVenues = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
	
	//now grab the venues in each group	
	NSArray * venuesInGroup = [inputNode nodesForXPath:@"venue" error:nil];
	for (CXMLElement *venueResult in venuesInGroup) {
		FSVenue * newVenue = [[FSVenue alloc] init];
		int counter;
		for(counter = 0; counter < [venueResult childCount]; counter++) {
			NSString * key = [[venueResult childAtIndex:counter] name];
			NSString * value = [[venueResult childAtIndex:counter] stringValue];
			
			if([key isEqualToString:@"id"]){
				newVenue.venueid = value;
			} else if([key isEqualToString:@"phone"]){
				newVenue.phone = value;
			} else if([key isEqualToString:@"geolat"]){
				newVenue.geolat = value;
			} else if([key isEqualToString:@"geolong"]){
				newVenue.geolong = value;
			} else if([key isEqualToString:@"name"]){
				newVenue.name = value;
			} else if([key isEqualToString:@"crossstreet"]){
				newVenue.crossStreet = value;
			} else if([key isEqualToString:@"address"]){
				newVenue.venueAddress = value;
			} else if([key isEqualToString:@"city"]){
				newVenue.city = value;
			} else if([key isEqualToString:@"state"]){
				newVenue.venueState = value;
			} else if([key isEqualToString:@"zip"]){
				newVenue.zip = value;
			} else if([key isEqualToString:@"twitter"]){
				newVenue.twitter = value;
			} else if([key isEqualToString:@"tips"]){
				newVenue.tips = [FoursquareAPI _tipsFromNode:venueResult];
			} else if([key isEqualToString:@"stats"]){
				NSArray * mayorNodes = [venueResult nodesForXPath:@"stats/mayor/user" error:nil];
				if(mayorNodes && [mayorNodes count] > 0){
					newVenue.mayor = [FoursquareAPI _userFromNode:[mayorNodes objectAtIndex:0]];
				}
				
				NSArray * countNodes = [venueResult nodesForXPath:@"stats/count" error:nil];
				if(countNodes && [countNodes count] > 0){
					CXMLNode * countNode = [countNodes objectAtIndex:0];
					newVenue.mayorCount = [[countNode stringValue]  intValue]; 
				}
				
				NSArray * checkinNodes = [venueResult nodesForXPath:@"stats/checkins" error:nil];
				if(checkinNodes && [checkinNodes count] > 0){
					CXMLNode * checkinsNode = [checkinNodes objectAtIndex:0];
					newVenue.userCheckinCount = [[checkinsNode stringValue]  intValue]; 
				}

			} 
            else if([key isEqualToString:@"checkins"]){
                NSLog(@"checkin name: %@", value);
				NSArray * allCheckinAttrs = [venueResult nodesForXPath:@"//venue/checkins" error:nil];
                for (CXMLElement *checkinAttr in allCheckinAttrs) {
                    newVenue.currentCheckins = [FoursquareAPI _checkinsFromNode:checkinAttr];
                    break;
                }
                
//                [FoursquareAPI _checkinsFromNode:<#(CXMLNode *)inputNode#>
//                if ([allCheckinTags count] > 0) {
//                    NSMutableArray * allCheckins = [[NSMutableArray alloc] initWithCapacity:1];
//                    for (CXMLElement *checkinTag in allCheckinTags) {
//                        NSLog(@"looping through checkins: %@", checkinTag);
//                        [allCheckins addObject:[FoursquareAPI _checkinFromNode:checkinTag]];
//                    }
//                    newVenue.currentCheckins = allCheckins;   
//                }
            } 
            else if ([key compare:@"specials"] == 0) {
                NSArray *specialNodes = [venueResult nodesForXPath:@"//specials/special" error:nil];
                NSMutableArray *specialArray = [[NSMutableArray alloc] initWithCapacity:1];
                for (CXMLElement *specialNode in specialNodes) {
                    FSSpecial *special = [[FSSpecial alloc] init];
                    for (int counter = 0; counter < [specialNode childCount]; counter++) {
                        NSString * key = [[specialNode childAtIndex:counter] name];
                        NSString * value = [[specialNode childAtIndex:counter] stringValue];
                        if ([key isEqualToString:@"message"]) {
                            special.message = value;
                        } else if ([key isEqualToString:@"id"]) {
                            special.specialId = value;
                        } else if ([key isEqualToString:@"type"]) {
                            special.type = value;
                        } else if ([key isEqualToString:@"venue"]) {
                            // FIXME: this was done for expediency's sake
                            NSArray *venueArray = [FoursquareAPI _venuesFromNode:[[venueResult nodesForXPath:@"//special" error:nil] objectAtIndex:0]];
                            if ([venueArray count] > 0) {
                                special.venue = [venueArray objectAtIndex:0];
                            }
                        }
                    }
                    [specialArray addObject:special];
                    [special release];
                }
                newVenue.specials = specialArray;
                [specialArray release];
            }
			
		}
		[groupOfVenues addObject:newVenue];
        [newVenue release];
	}

	return groupOfVenues;
}

+ (NSArray *) _tipsFromNode:(CXMLNode *) inputNode{
	NSMutableArray * allTips = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
	
	NSArray * tips = [inputNode nodesForXPath:@"//tip" error:nil];
	for (CXMLElement *tipResult in tips) {
		FSTip * newTip = [[FSTip alloc] init];
		int counter;
		for(counter = 0; counter < [tipResult childCount]; counter++) {
			NSString * key = [[tipResult childAtIndex:counter] name];
			NSString * value = [[tipResult childAtIndex:counter] stringValue];
			
			if([key isEqualToString:@"id"]){
				newTip.tipId = value;
			} else if([key isEqualToString:@"text"]){
				newTip.text = value;
			} else if([key isEqualToString:@"url"]){
				newTip.url = value;
			}  else if([key isEqualToString:@"user"]){
				newTip.submittedBy = [FoursquareAPI _shortUserFromNode:[[tipResult nodesForXPath:@"user" error:nil] objectAtIndex:0]];
			}
		}
		[allTips addObject:newTip];
        [newTip release];
	}
	
	return allTips;
}

+ (NSArray *) _badgesFromNode:(CXMLNode *) inputNode {
    NSMutableArray * loggedUserBadges = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    NSArray * userBadgeXML = [inputNode nodesForXPath:@"//badges/badge" error:nil];
    for (CXMLElement *loggedBadge in userBadgeXML) {
        FSBadge * currentBadgeInfo = [[FSBadge alloc] init];
        int counter;
        for(counter = 0; counter < [loggedBadge childCount]; counter++) {
            NSString * key = [[loggedBadge childAtIndex:counter] name];
            NSString * value = [[loggedBadge childAtIndex:counter] stringValue];
            if([key isEqualToString:@"id"]){
                currentBadgeInfo.badgeId = value;
            } else if([key isEqualToString:@"name"]){
                currentBadgeInfo.badgeName = value;
            } else if([key isEqualToString:@"icon"]){
                currentBadgeInfo.icon = value;
            } else if([key isEqualToString:@"description"]){
                currentBadgeInfo.badgeDescription = value;
            }
        }
        [loggedUserBadges addObject:currentBadgeInfo];
        [currentBadgeInfo release];
    }
    return loggedUserBadges;
}

+ (NSArray *) _friendsFromNode:(CXMLNode *) inputNode{
	NSMutableArray * allFriends = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
	
	NSArray * friends = [inputNode nodesForXPath:@"//friend" error:nil];
	for (CXMLElement *friendResult in friends) {
		FSUser * newFriend = [[FSUser alloc] init];
		int counter;
		for(counter = 0; counter < [friendResult childCount]; counter++) {
			NSString * key = [[friendResult childAtIndex:counter] name];
			NSString * value = [[friendResult childAtIndex:counter] stringValue];
			
			if([key isEqualToString:@"id"]){
				newFriend.userId = value;
			} else if([key isEqualToString:@"firstname"]){
				newFriend.firstname = value;
			} else if([key isEqualToString:@"lastname"]){
				newFriend.lastname = value;
			} 
		}
		[allFriends addObject:newFriend];
        [newFriend release];
	}
	
	return allFriends;
}

//+ (FSCheckin *) _checkinFromNode:(CXMLNode *) inputNode{
//    FSCheckin *checkin = [[FSCheckin alloc] init];
//    
////	NSArray * checkins = [inputNode nodesForXPath:@"//checkin" error:nil];
////	for (CXMLElement *checkinResult in checkins) {
////	//for(counter = 0; counter < [usrAttr childCount]; counter++) {
////    CXMLElement *checkinResult = [inputNode 
////		NSString * key = [[inputNode childAtIndex:counter] name];
////		NSString * value = [[inputNode childAtIndex:counter] stringValue];
////        
////        if ([key isEqualToString:@"id"]) {
////            checkin.checkinId = value;
////        } else if ([key isEqualToString:@"display"]) {
////            checkin.display = value;
////        }
////    }
//    
//    return checkin;
//}

// very short version of user for certain uses (e.g., tips)
+ (FSUser *) _shortUserFromNode:(CXMLElement *) usrAttr {
    
	FSUser * loggedInUser = [[FSUser alloc] init];
    
	int counter;
    
	for(counter = 0; counter < [usrAttr childCount]; counter++) {
		NSString * key = [[usrAttr childAtIndex:counter] name];
		NSString * value = [[usrAttr childAtIndex:counter] stringValue];
		
		if([key isEqualToString:@"id"]){
			loggedInUser.userId = value;
		} else if([key isEqualToString:@"firstname"]){
			loggedInUser.firstname = value;
		} else if([key isEqualToString:@"lastname"]){
			loggedInUser.lastname = value;
		} else if([key isEqualToString:@"gender"]){
			loggedInUser.gender = value;
		} else if([key isEqualToString:@"twitter"]){
			loggedInUser.twitter = value;
		}
    }
    return loggedInUser;
}

+ (FSUser *) _userFromNode:(CXMLElement *) usrAttr {

	FSUser * loggedInUser = [[FSUser alloc] init];

	int counter;

	for(counter = 0; counter < [usrAttr childCount]; counter++) {
		NSString * key = [[usrAttr childAtIndex:counter] name];
		NSString * value = [[usrAttr childAtIndex:counter] stringValue];
		
		if([key isEqualToString:@"id"]){
			loggedInUser.userId = value;
		} else if([key isEqualToString:@"photo"]){
			loggedInUser.photo = value;
            //[[Utilities sharedInstance] cacheImage:loggedInUser.photo];
		} else if([key isEqualToString:@"firstname"]){
			loggedInUser.firstname = value;
		} else if([key isEqualToString:@"lastname"]){
			loggedInUser.lastname = value;
		} else if([key isEqualToString:@"gender"]){
			loggedInUser.gender = value;
		} else if([key isEqualToString:@"twitter"]){
			loggedInUser.twitter = value;
		} else if([key isEqualToString:@"email"]){
			loggedInUser.email = value;
		} else if([key isEqualToString:@"phone"]){
			loggedInUser.phone = value;
		} else if([key isEqualToString:@"facebook"]){
			loggedInUser.facebook = value;
		} else if([key isEqualToString:@"friendstatus"]){
            loggedInUser.isFriend = NO;
            if ([value isEqualToString:@"friend"]) {
                loggedInUser.isFriend = YES;
                loggedInUser.friendStatus = FSStatusFriend;
            } else if ([value isEqualToString:@"pendingyou"]) {
                loggedInUser.friendStatus = FSStatusPendingYou;
            } else if ([value isEqualToString:@"pendingthem"]) {
                loggedInUser.friendStatus = FSStatusPendingThem;
            } else {
                loggedInUser.friendStatus = FSStatusNotFriend;
            }
		} else if([key isEqualToString:@"settings"]){
			NSArray * settingsXML = [usrAttr nodesForXPath:@"//settings" error:nil];
            NSLog(@"settings xml: %@", settingsXML);
			for (CXMLElement *settingsNode in settingsXML) {
                for (int counter = 0; counter < [settingsNode childCount]; counter++) {
					NSString * key = [[settingsNode childAtIndex:counter] name];
					NSString * value = [[settingsNode childAtIndex:counter] stringValue];
                    if ([key isEqualToString:@"sendtotwitter"]) {
                        loggedInUser.sendToTwitter = [value isEqualToString:@"true"];
                    } else if ([key isEqualToString:@"sendtofacebook"]) {
                        loggedInUser.sendToFacebook = [value isEqualToString:@"true"];
                    } else if ([key isEqualToString:@"pings"]) {
                        loggedInUser.isPingOn = [value isEqualToString:@"on"];
                    } else if ([key isEqualToString:@"get_pings"]) {
                        loggedInUser.sendsPingsToSignedInUser = [value isEqualToString:@"true"];
                    }
                }
            }
//		} else if([key isEqualToString:@"city"]){
//			NSArray * userCityXML = [usrAttr nodesForXPath:@"/city" error:nil];
//			for (CXMLElement *userCityNode in userCityXML) {
//				FSCity * userCity = [[FSCity alloc] init];
//				int counter;
//				for(counter = 0; counter < [userCityNode childCount]; counter++) {
//					NSString * key = [[userCityNode childAtIndex:counter] name];
//					NSString * value = [[userCityNode childAtIndex:counter] stringValue];
//					if([key isEqualToString:@"id"]){
//						userCity.cityid = value;
//					} else if([key isEqualToString:@"name"]){
//						userCity.cityname = value;
//					} else if([key isEqualToString:@"timezone"]){
//						userCity.citytimezone = value;
//					}
//				}
//				loggedInUser.userCity = userCity;
//			}
		} else if([key compare:@"mayor"] == 0){
			NSArray * userMayorshipXML = [usrAttr nodesForXPath:@"//mayor" error:nil];
			if([userMayorshipXML count] > 0){
				NSArray * loggedMayorships = [FoursquareAPI _venuesFromNode:[userMayorshipXML objectAtIndex:0]];
				loggedInUser.mayorOf = loggedMayorships;
			}
		} else if([key compare:@"badges"] == 0){
			NSArray * badgeXML = [usrAttr nodesForXPath:@"//badges" error:nil];
            if ([badgeXML count] > 0) {
                loggedInUser.badges = [FoursquareAPI _badgesFromNode:[badgeXML objectAtIndex:0]];
            }
		} else if ([key compare:@"checkin"] == 0){
			NSArray * userCheckinXML = [usrAttr nodesForXPath:@"//checkin" error:nil];
            NSLog(@"user's last checkin: %@", [userCheckinXML objectAtIndex:0]);
            CXMLElement *checkinElement = [userCheckinXML objectAtIndex:0];
            FSCheckin *checkin = [[FSCheckin alloc] init];
            NSLog(@"childcount: %d", [checkinElement childCount]);
            for (int i = 0; i < [checkinElement childCount]; i++) {
                NSLog(@"counter: %d", i);
                NSString * key = [[checkinElement childAtIndex:i] name];
                NSString * value = [[checkinElement childAtIndex:i] stringValue];
                if ([key isEqualToString:@"id"]) {
                    checkin.checkinId = value;
                } else if([key isEqualToString:@"shout"]){
                    checkin.shout = value;
                } else if ([key isEqualToString:@"display"]) {
                    checkin.display = value;
                } else if ([key isEqualToString:@"venue"]) {
                    NSArray * checkinVenueXML = [usrAttr nodesForXPath:@"//checkin/venue" error:nil];
                    CXMLElement *checkinVenueElement = [checkinVenueXML objectAtIndex:0];
                    NSLog(@"checkin venue element: %@", checkinVenueElement);
                    FSVenue *checkinVenue = [[FSVenue alloc] init];
                    for (int j = 0; j < [checkinVenueElement childCount]; j++) {
                        NSString * key2 = [[checkinVenueElement childAtIndex:j] name];
                        NSString * value2 = [[checkinVenueElement childAtIndex:j] stringValue];
                        if ([key2 isEqualToString:@"address"]) {
                            checkinVenue.venueAddress = value2;
                        } else if ([key2 isEqualToString:@"name"]) {
                            checkinVenue.name = value2;
                        } else if ([key2 isEqualToString:@"id"]) {
                            checkinVenue.venueid = value2;
                        } else if([key2 isEqualToString:@"city"]) {
                            checkinVenue.city = value2;
                        } else if([key2 isEqualToString:@"state"]) {
                            checkinVenue.venueState = value2;
                        }
                    }
                    checkin.venue = checkinVenue;
                    [checkinVenue release];
                }
            }
            loggedInUser.checkin = checkin;
            [checkin release];
            //loggedInUser.checkin = [FoursquareAPI _checkinFromNode:[userCheckinXML objectAtIndex:0]];
        }
    }
	return loggedInUser;
}


int encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
	char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz"
	"0123456789"
	"+/";
	
	unsigned triad;
	
	for (triad = 0; triad < s_len; triad += 3)
	{
		unsigned long int sr;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
		{
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) return 1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte)
		{
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}
	
	return 0;
	
}
+ (NSString *)parameterStringForDictionary:(NSDictionary *)inParameterDictionary {
	NSMutableString *queryString = [[NSMutableString alloc] init];
	int i = 0;
	
	for (NSString *aKey in [inParameterDictionary allKeys]) {
		if (i > 0) {
			[queryString appendString:@"&"];
		}
		[queryString appendFormat:@"%@=%@", [aKey stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[inParameterDictionary objectForKey:aKey] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		i++;
	}
	
	return [queryString autorelease];
}


- (void) loadBasicAuthURL:(NSURL *) url withUser:(NSString *) loginString andPassword: (NSString *) passwordString andParams:(NSDictionary *) parameters withTarget:(id)inTarget andAction:(SEL)inAction usingMethod:(NSString *) httpMethod{
	if(activeRequests == nil){
		
		activeRequests = [[NSMutableDictionary alloc] initWithCapacity:1];

	}
	
    NSMutableString *dataStr = (NSMutableString*)[@"" stringByAppendingFormat:@"%@:%@", loginString, passwordString];
	
    NSData *encodeData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    char encodeArray[512];
	
    memset(encodeArray, '\0', sizeof(encodeArray));
	
    // Base64 Encode username and password
    encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	NSData * data = [[NSData alloc] initWithBytes:encodeArray length:strlen(encodeArray)];
    dataStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString * authenticationString = [@"" stringByAppendingFormat:@"Basic %@", dataStr];
	[dataStr release];
    // Create asynchronous request
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [theRequest addValue:authenticationString forHTTPHeaderField:@"Authorization"];
    [theRequest addValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
	
	if(httpMethod == nil){
		httpMethod = @"GET";
	}
	
	NSMutableString *parameterString = [[NSMutableString alloc] initWithString:[FoursquareAPI parameterStringForDictionary:parameters]];

	if(httpMethod == @"POST"){
		//this is a post so do some form encoding
		NSData *postData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];		
		[theRequest setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
		[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[theRequest setHTTPBody:postData];
	} else {
			//its a get so put them on the URL
		
		NSString *urlString = [NSString stringWithFormat:@"%@?%@", [url absoluteString], parameterString];		
		[theRequest setURL:[NSURL URLWithString:urlString]];
		
	}
	
	[theRequest setHTTPMethod:httpMethod];
    NSURLConnection * theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (theConnection) {
		FSFunctionRequest * fsReq = [[FSFunctionRequest alloc] init];
		
		fsReq.currentTarget = [inTarget retain];
		fsReq.currentSelector = inAction;
		fsReq.currentRequestURL = [url retain];
		fsReq.receivedData = [[[NSMutableData alloc] initWithCapacity:15] retain];
		[fsReq retain];
		[activeRequests setObject:fsReq forKey:[NSString stringWithFormat:@"%d", [theConnection hash]]];

//		[inTarget performSelector:inAction withObject:url withObject:receivedData];	

    }
    else {
		NSLog(@"Could not connect to the network");
    }
	
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	FSFunctionRequest * fsReq = (FSFunctionRequest *) [activeRequests objectForKey:[NSString stringWithFormat:@"%d", [connection hash]]]; 

	
    [fsReq.receivedData setLength:0];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	FSFunctionRequest * fsReq = (FSFunctionRequest *) [activeRequests objectForKey:[NSString stringWithFormat:@"%d", [connection hash]]]; 
    [fsReq.receivedData appendData:data];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	FSFunctionRequest * fsReq = (FSFunctionRequest *) [activeRequests objectForKey:[NSString stringWithFormat:@"%d", [connection hash]]]; 
    
    NSLog(@"Succeeded! Received %d bytes of data",[fsReq.receivedData length]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSString * responseString = [[NSString alloc] initWithData:fsReq.receivedData encoding:NSUTF8StringEncoding];
	[fsReq.currentTarget performSelector:fsReq.currentSelector withObject:fsReq.currentRequestURL withObject:responseString];	
//    [responseString release];
    [connection release];
	[activeRequests removeObjectForKey:[NSString stringWithFormat:@"%d", [connection hash]]]; 
}

@end
