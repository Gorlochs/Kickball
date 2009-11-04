//
//  FoursquareAPI.h
//  FSApi
//
//  Created by David Evans on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"
#import "MPOAuth.h"
#import "MPURLRequestParameter.h"
#import "FSVenue.h"
#import "FSUser.h"
#import "FSBadge.h"
#import "FSCheckin.h"

#define kConsumerKey		@"56db3be85201b7c551d458354075499b04adbd869"
#define kConsumerSecret		@"b6439213b40bec023df4da248ed83050"

@class MPOAuthAPI;

@interface FoursquareAPI : NSObject {
	MPOAuthAPI * oauthAPI;
}

@property (nonatomic, retain) MPOAuthAPI * oauthAPI;


- (BOOL) isAuthenticated;
- (void)getVeneusNearLatitude:(NSString *)geolat andLongitude:(NSString *)geolong withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getCheckinsWithTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getUserWithTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getUserById:(NSString *) userId ithTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getFriendsWithTarget:(id)inTarget andAction:(SEL)inAction;


- (void)doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass;


+ (FoursquareAPI *)sharedInstance;

+ (NSArray *) _venuesFromNode:(CXMLNode *) inputNode;
+ (NSArray *) _friendsFromNode:(CXMLNode *) inputNode;
+ (FSUser *) _userFromNode:(CXMLElement *) usrAttr;

+ (NSArray *) friendsFromResponseXML:(NSString *) inString;
+ (NSArray *) venuesFromResponseXML:(NSString *) inString;
+ (FSUser *) loggedInUserFromResponseXML:(NSString *) inString; 
+ (NSArray *) checkinsFromResponseXML:(NSString *) inString;

@end
