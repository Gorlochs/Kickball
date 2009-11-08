//
//  FoursquareAPI.m
//  FSApi
//
//  Created by David Evans on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FoursquareAPI.h"


static FoursquareAPI *sharedInstance = nil;

@implementation FoursquareAPI

@synthesize oauthAPI;

#pragma mark -
#pragma mark class instance methods

#pragma mark -
#pragma mark Singleton methods

+ (FoursquareAPI*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[FoursquareAPI alloc] init];
			NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	kConsumerKey, kMPOAuthCredentialConsumerKey,
										 kConsumerSecret, kMPOAuthCredentialConsumerSecret,
										 nil];
			
			
			sharedInstance.oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
								  authenticationURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/authexchange"]
														 andBaseURL:[NSURL URLWithString:@"http://api.foursquare.com"]];
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
	NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	kConsumerKey, kMPOAuthCredentialConsumerKey,
								 kConsumerSecret, kMPOAuthCredentialConsumerSecret,
								 nil];
	
	self.oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
									  authenticationURL:[NSURL URLWithString:@"http://api.foursquare.com/v1/authexchange"]
											 andBaseURL:[NSURL URLWithString:@"http://api.foursquare.com"]
											 fsUsername:fsUser
											 fsPassword:fsPass];
	self.oauthAPI.delegate = (id <MPOAuthAPIDelegate>)[UIApplication sharedApplication].delegate;

}

- (BOOL) isAuthenticated{
	
	NSString *accessTokenSecret = [self.oauthAPI findValueFromKeychainUsingName:@"oauth_token_access_secret"];
	if(accessTokenSecret != nil){
		return YES;
	} else return NO;
}


- (void)getVenuesNearLatitude: (NSString *)geolat andLongitude:(NSString *) geolong withTarget:(id)inTarget andAction:(SEL)inAction{
	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
	
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolat" andValue:geolat]];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolong" andValue:geolong]];
	
	[self.oauthAPI performMethod:@"/v1/venues" withTarget:inTarget withParameters:params  andAction:inAction];
	
}

// this might could be combined with the above method
- (void)getVenuesByKeyword: (NSString *)geolat andLongitude:(NSString *) geolong andKeywords:(NSString *) keywords withTarget:(id)inTarget andAction:(SEL)inAction{
	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
	
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolat" andValue:geolat]];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"geolong" andValue:geolong]];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"q" andValue:[keywords stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
	
	[self.oauthAPI performMethod:@"/v1/venues" withTarget:inTarget withParameters:params  andAction:inAction];
	
}

- (void)getVenue:(NSString *)venueId withTarget:(id)inTarget andAction:(SEL)inAction{
	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"vid" andValue:venueId]];
	[self.oauthAPI performMethod:@"/v1/venue" withTarget:inTarget withParameters:params  andAction:inAction];
}

- (void)getUser:(NSString *)userId withTarget:(id)inTarget andAction:(SEL)inAction{
	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"uid" andValue:userId]];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"badges" andValue:@"1"]];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"mayor" andValue:@"1"]];
	
	
	[self.oauthAPI performMethod:@"/v1/user" withTarget:inTarget withParameters:params  andAction:inAction];
}

- (void)getCheckinsWithTarget:(id)inTarget andAction:(SEL)inAction{
	[self.oauthAPI performMethod:@"/v1/checkins" withTarget:inTarget andAction:inAction];

}

- (void)getFriendsWithTarget:(id)inTarget andAction:(SEL)inAction{
	[self.oauthAPI performMethod:@"/v1/friends" withTarget:inTarget andAction:inAction];
}

- (void)getUserWithTarget:(id)inTarget andAction:(SEL)inAction{
	NSMutableArray * params = [[NSMutableArray alloc] initWithCapacity:1];
	
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"badges" andValue:@"1"]];
	[params addObject:[[MPURLRequestParameter alloc] initWithName:@"mayor" andValue:@"1"]];
	[self.oauthAPI performMethod:@"/v1/user" withTarget:inTarget withParameters:params andAction:inAction];
}

- (void)getUserById:(NSString *) userId withTarget:(id)inTarget andAction:(SEL)inAction{
	
}

+ (NSArray *) friendsFromResponseXML:(NSString *) inString{
	
	NSError * err;
	CXMLDocument *friendParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"%@", [err localizedDescription]);
	
	NSArray * allFriends;
	
	//get the groups
	allFriends = [friendParser nodesForXPath:@"//friends/friend" error:nil];
	for (CXMLElement *friendResult in allFriends) {
		allFriends = [[FoursquareAPI _friendsFromNode:friendResult] mutableCopy];
	}
	return allFriends;
}

+ (NSArray *) venuesFromResponseXML:(NSString *) inString{

	NSError * err;
	CXMLDocument *venueParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"venues xml: %@", venueParser);
	NSLog(@"%@", [err localizedDescription]);

	NSMutableArray * allVens = [[NSMutableArray alloc] initWithCapacity:1];

	NSArray *allGroups = NULL;

	//get the groups
	allGroups = [venueParser nodesForXPath:@"//venues/group" error:nil];
	for (CXMLElement *groupResult in allGroups) {
		NSArray * groupOfVenues = [FoursquareAPI _venuesFromNode:groupResult];
		[allVens addObject:[groupOfVenues copy]];
	}
	return allVens;
}

+ (FSVenue *) venueFromResponseXML:(NSString *) inString{
	
	NSError * err;
	CXMLDocument *venueParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"venue xml: %@", venueParser);
	FSVenue * thisVenue = [[FSVenue alloc] init];
	
	NSArray *allGroups = [venueParser nodesForXPath:@"/" error:nil];
	
	for (CXMLElement *groupResult in allGroups) {
		NSArray * groupOfVenues = [FoursquareAPI _venuesFromNode:groupResult];
        NSLog(@"group of venues: %@", groupOfVenues);
		thisVenue = (FSVenue *)[groupOfVenues objectAtIndex:0];
	}
	return thisVenue;
}

+ (FSUser *) userFromResponseXML:(NSString *) inString{
	
	NSError * err;
	CXMLDocument *userParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"%@", [err description]);

	FSUser * thisUser = [[FSUser alloc] init];
	
	NSArray *allUserAttrs = [userParser nodesForXPath:@"user" error:nil];
	for (CXMLElement *usrAttr in allUserAttrs) {
		return [FoursquareAPI _userFromNode:usrAttr];
	}
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
	
	return nil;
}

+ (NSArray *) checkinsFromResponseXML:(NSString *) inString{
	NSError * err;
	CXMLDocument *checkinParser = [[CXMLDocument alloc] initWithXMLString:inString options:0 error:&err];
	NSLog(@"%@", [err localizedDescription]);
	
	NSMutableArray * allCheckins = [[NSMutableArray alloc] initWithCapacity:1];
	NSLog(@"checkins xml: %@", checkinParser);

	NSArray *allCheckinAttrs = NULL;
	
	allCheckinAttrs = [checkinParser nodesForXPath:@"//checkins/checkin" error:nil];
	for (CXMLElement *checkinAttr in allCheckinAttrs) {
		FSCheckin * oneCheckin = [[FSCheckin alloc] init];
		int counter;
		for(counter = 0; counter < [checkinAttr childCount]; counter++) {
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
			}
		
			if([key compare:@"user"] == 0){
				NSArray * checkinUser = [checkinAttr elementsForName:@"user"];
				for (CXMLElement *checkedUser in checkinUser) {
					FSUser * currentUserInfo = [FoursquareAPI _userFromNode:checkedUser];
					oneCheckin.user = currentUserInfo;
				}
			} else 			
			if([key compare:@"venue"] == 0){
					FSVenue * currentVenueInfo = [[FoursquareAPI _venuesFromNode:checkinAttr] objectAtIndex:0];
					oneCheckin.venue = currentVenueInfo;
			}

		}
		[allCheckins addObject:[oneCheckin retain]];
	}
	return allCheckins;
}

+ (NSArray *) _venuesFromNode:(CXMLNode *) inputNode{
	NSMutableArray * groupOfVenues = [[NSMutableArray alloc] initWithCapacity:1];
	
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
			} else if([key isEqualToString:@"mayor"]){
				newVenue.mayor = [FoursquareAPI _userFromNode:venueResult];
			}
			
		}
		[groupOfVenues addObject:newVenue];
	}
	
	return groupOfVenues;
}

+ (NSArray *) _tipsFromNode:(CXMLNode *) inputNode{
	NSMutableArray * allTips = [[NSMutableArray alloc] initWithCapacity:1];
	
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
				newTip.submittedBy = [FoursquareAPI _userFromNode:[[tipResult nodesForXPath:@"user" error:nil] objectAtIndex:0]];
			}
		}
		[allTips addObject:newTip];
	}
	
	return allTips;
}

+ (NSArray *) _friendsFromNode:(CXMLNode *) inputNode{
	NSMutableArray * allFriends = [[NSMutableArray alloc] initWithCapacity:1];
	
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
	}
	
	return allFriends;
}


+ (FSUser *) _userFromNode:(CXMLElement *) usrAttr{

	FSUser * loggedInUser = [[FSUser alloc] init];

	int counter;

	for(counter = 0; counter < [usrAttr childCount]; counter++) {
		NSString * key = [[usrAttr childAtIndex:counter] name];
		NSString * value = [[usrAttr childAtIndex:counter] stringValue];
		
		if([key isEqualToString:@"id"]){
			loggedInUser.userId = value;
		} else if([key isEqualToString:@"photo"]){
			loggedInUser.photo = value;
		} else if([key isEqualToString:@"firstname"]){
			loggedInUser.firstname = value;
		} else if([key isEqualToString:@"lastname"]){
			loggedInUser.lastname = value;
		} else if([key isEqualToString:@"gender"]){
			loggedInUser.gender = value;
		} else if([key compare:@"badges"] == 0){
			NSMutableArray * loggedUserBadges = [[NSMutableArray alloc] initWithCapacity:1];
			//badges and city are special cases
			NSArray * userBadgeXML = [usrAttr nodesForXPath:@"//badges/badge" error:nil];
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
						currentBadgeInfo.description = value;
					}
				}
				[loggedUserBadges addObject:currentBadgeInfo];
			}
			loggedInUser.badges = loggedUserBadges;
		}
	}
	return loggedInUser;
}

@end
