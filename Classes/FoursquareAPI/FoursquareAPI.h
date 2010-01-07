//
//  FoursquareAPI.h
//  FSApi
//
//  Created by David Evans on 11/1/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"
#import "MPOAuth.h"
#import "MPURLRequestParameter.h"
#import "FSVenue.h"
#import "FSUser.h"
#import "FSBadge.h"
#import "FSCheckin.h"
#import "FSTip.h"
#import "FSCity.h"
#import "FSScoring.h"
#import "FSScore.h"
#import "FSFunctionRequest.h"


#define kConsumerKey		@"56db3be85201b7c551d458354075499b04adbd869"
#define kConsumerSecret		@"b6439213b40bec023df4da248ed83050"

@class MPOAuthAPI;

@interface FoursquareAPI : NSObject {
	MPOAuthAPI * oauthAPI;
	FSUser * currentUser;
	NSString * userName;
	NSString * passWord;
	NSMutableDictionary * activeRequests;
}

@property (nonatomic, retain) MPOAuthAPI * oauthAPI;
@property (nonatomic, retain) FSUser * currentUser;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * passWord;
@property (nonatomic, retain) NSMutableDictionary * activeRequests;

- (BOOL) isAuthenticated;
- (void)getVenuesNearLatitude:(NSString *)geolat andLongitude:(NSString *)geolong withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getVenuesByKeyword: (NSString *)geolat andLongitude:(NSString *) geolong andKeywords:(NSString *) keywords withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getCheckinsWithTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getUserWithTarget:(id)inTarget andAction:(SEL)inAction;
//- (void)getUserById:(NSString *) userId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getCityNearestToLatitude:(NSString *) geolat andLongitude:(NSString *)geolong withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getFriendsWithTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getVenue:(NSString *)venueId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)getUser:(NSString *)userId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)setPings:(NSString*)pingStatus forUser:(NSString *)userId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) doVenuelessCheckin:(NSString*)venueName withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) doCheckinAtVenueWithId:(NSString *)venueId andShout:(NSString *)shout offGrid:(BOOL)offGrid toTwitter:(BOOL)toTwitter withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) doSendFriendRequest:(NSString*)userId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) approveFriendRequest:(NSString*)userId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) denyFriendRequest:(NSString*)userId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) findFriendsByName:(NSString*)name withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) findFriendsByPhone:(NSString*)phone withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) findFriendsByTwitterName:(NSString*)phone withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) getPendingFriendRequests:(id)inTarget andAction:(SEL)inAction;
- (void) flagVenueAsClosed:(NSString*)venueId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) loadBasicAuthURL:(NSURL *) url withUser:(NSString *) loginString andPassword: (NSString *) passwordString andParams:(NSDictionary *) parameters withTarget:(id)inTarget andAction:(SEL)inAction usingMethod:(NSString *) httpMethod;
- (void) addNewVenue:(NSString*)name atAddress:(NSString*)address andCrossstreet:(NSString*)crossStreet andCity:(NSString*)city andState:(NSString*)state andOptionalZip:(NSString*)zip andRequiredCityId:(NSString*)cityId andOptionalPhone:(NSString*)phone  withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) createTipTodoForVenue:(NSString*)venueId type:(NSString*)tipOrTodo text:(NSString*)tipTodoText withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) markTipAsTodo:(NSString*)tipId withTarget:(id)inTarget andAction:(SEL)inAction;
- (void) markTipAsDone:(NSString*)tipId withTarget:(id)inTarget andAction:(SEL)inAction;

- (void)doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass;

+ (FoursquareAPI *)sharedInstance;

+ (NSArray *) _venuesFromNode:(CXMLNode *) inputNode;
+ (NSArray *) _friendsFromNode:(CXMLNode *) inputNode;
+ (FSUser *) _userFromNode:(CXMLElement *) usrAttr;
+ (FSUser *) _shortUserFromNode:(CXMLElement *) usrAttr;
+ (NSArray *) _tipsFromNode:(CXMLNode *) inputNode;
+ (FSScoring *) _scoringFromNode:(CXMLNode *) inputNode;
//+ (FSCheckin *) _checkinFromNode:(CXMLNode *) inputNode;
+ (NSArray *) _badgesFromNode:(CXMLNode *) inputNode;
+ (NSArray *) _checkinsFromNode:(CXMLNode *) inputNode;

+ (NSArray *) usersFromResponseXML:(NSString *) inString;
+ (NSArray *) usersFromRequestResponseXML:(NSString *) inString;
+ (NSArray *) friendsFromResponseXML:(NSString *) inString;
+ (NSDictionary *) venuesFromResponseXML:(NSString *) inString;
+ (FSUser *) loggedInUserFromResponseXML:(NSString *) inString; 
+ (NSArray *) checkinsFromResponseXML:(NSString *) inString;
+ (NSArray *) checkinFromResponseXML:(NSString *) inString;
+ (FSVenue *) venueFromResponseXML:(NSString *) inString;
+ (FSUser *) userFromResponseXML:(NSString *) inString;
+ (BOOL) pingSettingFromResponseXML:(NSString *) inString;
+ (BOOL) simpleBooleanFromResponseXML:(NSString *) inString;
+ (NSString*) tipIdFromResponseXML:(NSString *) inString;

@end
