//#import "FBConnect/FBConnect.h"
#import "FBConnect.h"

// Facebook API
// all of these values need to be set in the client application
extern NSString* const kFBAPIKey;
extern NSString* const kFBAppSecret;

extern NSString* const kFBClientID;
extern NSString* const kFBRedirectURI;

@class GraphAPI, GraphObject;

@interface FBDataDialog : FBDialog
{
	NSData* _webPageData;
}

@property (nonatomic, retain) NSData* _webPageData;

@end


@interface FacebookProxy : NSObject <NSCoding, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> //, UIWebViewDelegate>
{
	FBSession* _session;
	FBUID _uid;

	NSString* _oAuthAccessToken;
	
	id _authTarget;
	SEL _authCallback;

	NSMutableData* _authResponse;
	NSMutableData* _accessTokenResponse;
	
	NSString* _codeString;
	
//	NSURLRequest* _authConnection;
//	NSURLRequest* _accessTokenConnection;
	NSURLConnection* _authConnection;
	NSURLConnection* _accessTokenConnection;
	
	FBLoginDialog* _loginDialog;
	FBDataDialog* _permissionDialog;
	GraphAPI *_meGraph;
	GraphObject* _me;
	
	NSMutableDictionary *pictureUrls;
	UIImage *profilePic;
	
	NSMutableDictionary *profileLookup;
	NSMutableDictionary *albumLookup;
}

@property (nonatomic, retain) FBSession* _session;
@property (nonatomic, assign) FBUID _uid;

@property (nonatomic, retain) NSString* _oAuthAccessToken;

@property (nonatomic, assign) id _authTarget;
@property (nonatomic, assign) SEL _authCallback;

@property (nonatomic, retain) NSMutableData* _authResponse;
@property (nonatomic, retain) NSMutableData* _accessTokenResponse;
@property (nonatomic, retain) NSString* _codeString;

@property (nonatomic, retain) NSURLConnection* _authConnection;
@property (nonatomic, retain) NSURLConnection* _accessTokenConnection;

@property (nonatomic, retain) FBLoginDialog* _loginDialog;
@property (nonatomic, retain) FBDataDialog* _permissionDialog;
@property (nonatomic, retain) NSMutableDictionary *pictureUrls;
@property (nonatomic, retain) UIImage *profilePic;
@property (nonatomic, retain)NSMutableDictionary *profileLookup;
@property (nonatomic, retain)NSMutableDictionary *albumLookup;

+(FacebookProxy*)instance;
+(void)loadDefaults;
+(NSDateFormatter*)fbDateFormatter;
+(NSDateFormatter*)fbEventSectionFormatter;
+(NSDateFormatter*)fbEventCellTimeFormatter;
+(NSDateFormatter*)fbEventDetailMonthFormatter;
+(NSDateFormatter*)fbEventDetailDateFormatter;
//+(void)updateDefaults;

-(void)loginAndAuthorizeWithTarget:(id)target callback:(SEL)authCallback;

// use this to clear the memory, in case the user wants to logout, or any other similar situation
-(void)forgetToken;
-(void)logout;

-(GraphAPI*)newGraph;
-(void)doAuth;
-(void)logout;
-(NSArray*)refreshHome;
-(NSArray*)refreshEvents;
-(bool)isAuthorized;
-(void)storeProfilePic; // this was pulled out of loadDefaults

//convenience stuff
-(NSString*)findSuitableText:(NSDictionary*)fbItem;
-(BOOL)doesHavePhoto:(NSDictionary*)fbItem;
-(NSString*)userNameFrom:(id)_id;
-(NSString*)profilePicUrlFrom:(id)_id;
-(void)cacheIncomingProfiles:(NSArray*)profiles;
-(void)cacheIncomingAlbums:(NSArray*)albums;
-(NSString*)imageUrlForPhoto:(NSDictionary*)fbItem;
-(NSString*)albumIdForPhoto:(NSDictionary*)fbItem;
-(NSString*)albumNameFrom:(id)_id;
-(NSString*)normalizeIdAsString:(id)_id;
-(NSNumber*)photoIndexWithinGallery:(NSDictionary*)fbItem;
@end
