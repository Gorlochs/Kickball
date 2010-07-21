#import "FacebookProxy.h"
#import "GraphAPI.h"
#import "GraphObject.h"
#import "JSON.h"

// testing rediculousness
//#import "AppDelegate_Pad.h"
//#import "PadRootController.h"
//#import "FBLoginDialog.h"
//#import "FBDialog.h"

//FB original app

NSString* const kFBAPIKey = @"4585c2e42804bca19e21eb30d402905e";
NSString* const kFBAppSecret = @"5cd7d10f85a36d5aeb4f2f7f99e1c85b"; // @"<YOUR SECRET KEY>";

NSString* const kFBClientID = @"111456732216058";
NSString* const kFBRedirectURI = @"http://www.gorlochs.com/";

//FB app testing 
/*
NSString* const kFBAPIKey = @"a578686869ab8192e2eb00b22c0004c7";
NSString* const kFBAppSecret = @"03808784b1efd1be26a059e296016ca8";

NSString* const kFBClientID = @"127099537321605";
NSString* const kFBRedirectURI = @"http://www.gorlochs.com/";
 */

// URL Formats for code & access_token
NSString* const kFBAuthURLFormat = @"https://graph.facebook.com/oauth/authorize?display=touch&client_id=%@&redirect_uri=%@&scope=%@";
NSString* const kFBAccessTokenURLFormat = @"https://graph.facebook.com/oauth/access_token?client_id=%@&redirect_uri=%@&client_secret=%@&code=%@";

// Serialization keys
NSString* const kFacebookProxyKey = @"kFacebookProxyKey";
NSString* const kKeyAccessToken = @"kKeyAccessToken";

@interface FacebookProxy (_PrivateMethods)

-(void)authorize;
-(void)getSession;
-(void)loadAccessToken;

@end

#pragma mark -

@implementation FBDataDialog

@synthesize _webPageData;

#pragma mark Initialization

-(id)init
{
	if ( self = [super init] )
	{
		self._webPageData = nil;
	}
	return self;
}
-(void)dealloc
{
	[_webPageData release];
	[super dealloc];
}

#pragma mark Overrides

-(void)load
{
	if ( nil != self._webPageData )
	{
		[_webView loadData:self._webPageData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@""]];
//		[self loadData:self._webPageData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"https://www.facebook.com/connect/uiserver.php"]];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType 
{
  NSURL* url = request.URL;
	NSString* urlString = url.absoluteString;
	
	NSArray* splitStrings = [urlString componentsSeparatedByString:@"code="];
	
	if ( [splitStrings count] > 1 )
	{
		FacebookProxy* fb_p = [FacebookProxy instance];
		fb_p._codeString = [splitStrings objectAtIndex:1];
		NSLog( @"in FBDataDialog, codeString = [%@] close down the dialog", fb_p._codeString );
		[self dismissWithSuccess:YES animated:YES];
		[fb_p loadAccessToken];
		return NO;
	}	
	return YES;
}


@end

#pragma mark -

@implementation FacebookProxy

@synthesize _session;
@synthesize _uid;

@synthesize _oAuthAccessToken;

@synthesize _authTarget;
@synthesize _authCallback;

@synthesize _authResponse;
@synthesize _accessTokenResponse;
@synthesize _codeString;

@synthesize _authConnection;
@synthesize _accessTokenConnection;

@synthesize _loginDialog;
@synthesize _permissionDialog;

@synthesize pictureUrls;
@synthesize profilePic;
@synthesize profileLookup;
@synthesize albumLookup;

#pragma mark Singleton Methods

static FacebookProxy* gFacebookProxy = NULL;
static NSDateFormatter* fbDate = NULL;
static NSDateFormatter* fbEventSectionFmt = NULL;
static NSDateFormatter* fbEventCellTime = NULL;
static NSDateFormatter* fbEventDetailMonth = NULL;
static NSDateFormatter* fbEventDetailDate = NULL;


+(FacebookProxy*)instance
{
	@synchronized(self)
	{
    if (gFacebookProxy == NULL)
		{
			gFacebookProxy = [[FacebookProxy alloc] init];
		}
	}
	return gFacebookProxy;
}

#pragma mark Initialization

-(id)init
{
	if ( self = [super init] )
	{
		self._uid = 0;
//		[self getSession];
		self._session = nil;
		
		self._oAuthAccessToken = nil;
		self._authTarget = nil;
		self._authCallback = nil;
		self._authResponse = nil;
		self._accessTokenResponse = nil;
		self._codeString = nil;
		self._authConnection = nil;
		self._accessTokenConnection = nil;
		self._loginDialog = nil;
		self._permissionDialog = nil;
		self.pictureUrls = [[NSMutableDictionary alloc] init];
		self.profilePic = nil;
		self.profileLookup = [[NSMutableDictionary alloc] init];
		self.albumLookup = [[NSMutableDictionary alloc] init];

	}
	return self;
}

//-(void)initEvents
//{
//	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify:) name:@"Event" object:notificationSender];	
//}

//-(void)stopEvents
//{
//	//[[NSNotificationCenter defaultCenter] removeObserver:self @"Event" object:notificationSender];
//}

- (void)dealloc 
{
	//	[self stopEvents];
	if ( self._session != nil )
		[self._session.delegates removeObject:self];	
	
	[_oAuthAccessToken release];
	[_authResponse release];
	[_accessTokenResponse release];
	[_codeString release];

	// these are released in the callbacks, but maybe I'll change that sometime...
//	[_authConnection release];
//	[_accessTokenConnection release];

//	self._authConnection = nil;
//	self._accessTokenConnection = nil;
	
	_loginDialog.delegate = nil;
	[_loginDialog release];
	_permissionDialog.delegate = nil;
	[_permissionDialog release];
	[pictureUrls release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id)initWithCoder:(NSCoder *)coder;
{
	self = [[FacebookProxy alloc] init];
	if (self != nil)
	{
		self._oAuthAccessToken = [coder decodeObjectForKey:kKeyAccessToken]; 
	}   
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
	[coder encodeObject:self._oAuthAccessToken forKey:kKeyAccessToken];
}

#pragma mark NSDefaults Methods

+(void)loadDefaults
{
	@try
	{
		NSData* dataRepresentingSavedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kFacebookProxyKey];
		
		if ( dataRepresentingSavedObject != nil )
		{
			if ( gFacebookProxy != nil )
				[gFacebookProxy release];			
			gFacebookProxy = [[NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedObject] retain];
			gFacebookProxy.pictureUrls = [[NSMutableDictionary alloc] init];
			gFacebookProxy.profilePic = nil;
			//if (gFacebookProxy.profilePic==nil) {
				[gFacebookProxy storeProfilePic];
			//}
			gFacebookProxy.profileLookup = [[NSMutableDictionary alloc] init];
			gFacebookProxy.albumLookup = [[NSMutableDictionary alloc] init];

			
		}
		else
		{
		}
	}
	@catch (id theException) 
	{
//		[FlurryAPI logError:kErrorStatsLoadException message:@"FacebookProxy::loadDefaults" exception:theException];
	} 
	
}

+(void)updateDefaults
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[FacebookProxy instance]] forKey:kFacebookProxyKey];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}


#pragma mark -
#pragma mark Login Methods (Facebook Connect API)

-(void)getSession
{
	if ( ![self._session resume] )
	{
		NSLog( @"Starting new session" );
		self._session = [FBSession sessionForApplication:kFBAPIKey secret:kFBAppSecret delegate:self];
	}
	else 
	{
		NSLog( @"Session resumed!" );
	}
}

-(bool)isLoggedin
{
	return self._uid != 0;
}

-(void)login
{
	if ( nil == self._session )
		[self getSession];
	
	if ( self._session )
	{
		self._loginDialog = [[FBLoginDialog alloc] initWithSession:self._session];
		self._loginDialog.delegate = self;
		[self._loginDialog show];
	}
}

#pragma mark FBSessionDelegate Methods

- (void)session:(FBSession*)session didLogin:(FBUID)uid 
{
	self._uid = uid;
	NSLog(@"User with id %lld logged in.", self._uid);
}

#pragma mark FBDialogDelegate [Login Dialog] Methods

- (void)dialogDidSucceed:(FBDialog*)dialog
{
	if ( dialog == self._loginDialog )
	{
		NSLog( @"loginDialog DidSucceed" );
		[self authorize];
	}
	else
	{
		NSLog( @"permissionDialog DidSucceed" );
		// todo - now...we need to get the damn access_token, and it may have been swallowed up by the dialog
		[self loadAccessToken];		
	}
}

#pragma mark -
#pragma mark Authorization Methods (Graph API)

-(bool)isAuthorized
{
	return nil != self._oAuthAccessToken;
}

-(void)finishedAuthorizing
{
	if ( self._authTarget && self._authCallback)
	{
		[self._authTarget performSelector:self._authCallback];
	}			
}

// authorization has the following steps
// 1. get a code by calling https://graph.facebook.com/oauth/authorize
// 2. facebook will respond with a redirect, and a code in the URL parameter
// 3. read the code parameter, and call https://graph.facebook.com/oauth/access_token
// 4. in the body of the response will be an "access_token=xxx"
// 5. save the access_token for all future graph api calls, and call the delegate callback

// [ryan:5-31-10] this flow is out of date, it doesn't include the step necessary for extended permissions

-(void)authorize
{
	if ( ![self isAuthorized] )
	{
		// we default to asking for read_stream and publish_stream, if your app needs something different...this is the code to change
		// hardcoded for now, so at least we don't break when Facebook changes permissions on June 1
		NSString* accessTokenURL = [NSString stringWithFormat:kFBAuthURLFormat, kFBClientID, kFBRedirectURI, @"publish_stream,read_stream,offline_access,user_events,friends_events,user_hometown,friends_hometown,user_location,friends_location,user_status,friends_status,rsvp_event,create_event,user_photos,friends_photos,user_videos,friends_videos,read_requests,user_likes,friends_likes"];

		NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:accessTokenURL]
																							cachePolicy:NSURLRequestUseProtocolCachePolicy
																					timeoutInterval:60.0];
		// create the connection with the request
		// and start loading the data
		self._authConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		if ( nil != self._authConnection )
		{
			// Create the NSMutableData to hold the received data.
			self._authResponse = [NSMutableData data];
		} 
		else 
		{
			NSLog( @"authorize NSURLConnection fail" );
		}
	}
	else
	{
		[self finishedAuthorizing];
	}
}

-(void)loadAccessToken
{
	// now we have the code, and we need to go get the oAuth access_token.
	// an example url is:
	// https://graph.facebook.com/oauth/access_token?client_id=119908831367602&redirect_uri=http://oauth.twoalex.com/&client_secret=e45e55a333eec232d4206d2703de1307&code=674667c45691cbca6a03d480-1394987957%7CjN-9MVsdl0kjyoKRvQq3DbwxL4c.

	NSString* accessTokenURL = [NSString stringWithFormat:kFBAccessTokenURLFormat, kFBClientID, kFBRedirectURI, kFBAppSecret, self._codeString];

	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:accessTokenURL]
																							cachePolicy:NSURLRequestUseProtocolCachePolicy
																					timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	self._accessTokenConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if ( self._accessTokenConnection ) 
	{
		// Create the NSMutableData to hold the received data.
		self._accessTokenResponse = [NSMutableData data];
	} 
	else 
	{
		NSLog( @"authorize NSURLConnection fail" );
	}
}

#pragma mark NSURLConnectionDelegate

//  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//	RCLog( @"status: %@", [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] );
//	RCLog( @"headers: %@", [httpResponse allHeaderFields] );
//	RCLog( @"header keys: %@", [[httpResponse allHeaderFields] allKeys] );
//	RCLog( @"header values: %@", [[httpResponse allHeaderFields] allValues]);


//-(void)confirmExtendedPermissions:(NSString*)permUrl
//{
//	if ( nil == self._session )
//		[self getSession];
//	
//	if ( self._session )
//	{
//		FBDialog* dialog = [[[FBDialog alloc] initWithSession:self._session] autorelease];
//		dialog.delegate = self;
//		dialog.delegate = nil;
//		
////		NSDictionary* getParams = [NSDictionary dictionaryWithObjectsAndKeys:
////															 @"touch", @"display", nil];
//		[dialog loadURL:permUrl method:@"GET" get:nil post:nil];
//		[dialog show];
////		[getParams release];		
//	}
//}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response 
{
	NSLog( @"didReceiveResponse" );
 
	if ( connection == self._authConnection )
	{
		self._authResponse = [NSMutableData data];
		
		// the code we need is at the end of the URL in the response parameter
		// example: 
		// http://oauth.twoalex.com/?code=674667c45691cbca6a03d480-1394987957%7CjN-9MVsdl0kjyoKRvQq3DbwxL4c.

		NSString* responseURL = [[response URL] absoluteString];

		// [ryan:5-31-10] testing out a way to get the user to confirm the extended permissions we want
		//[self confirmExtendedPermissions:responseURL];

		NSArray* splitStrings = [responseURL componentsSeparatedByString:@"code="];
		
		if ( [splitStrings count] > 1 )
		{
			self._codeString = [splitStrings objectAtIndex:1];
			NSLog( @"codeString = [%@]", self._codeString );
		}
		else
		{
			NSLog( @"something is wrong with the auth URL: %@", responseURL );
			// [ryan:5-31-10] this probably means we need to authorize extended permissions
			// in that case, the data returned by this connection is the actual html web page that is the next page.
			// so lets set a flag here, and load it up later when it's all done.
			self._codeString = nil;

			//			[self confirmExtendedPermissions:responseURL];

//			assert( false );
		}
	}
	else if ( connection == self._accessTokenConnection )
	{
		self._accessTokenResponse = [NSMutableData data];
	}
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data 
{
	if ( connection == self._authConnection )
	{
		NSLog( @"didReceiveData._auth" );
		[self._authResponse appendData:data];
	}
	else if ( connection = self._accessTokenConnection )
	{		
		NSLog( @"didReceiveData._token" );
		[self._accessTokenResponse appendData:data];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection 
{
	if ( connection == self._authConnection )
	{
		NSLog( @"connectionDidFinishLoading._auth" );
		
		NSString* responseBody = [[NSString alloc] initWithData:self._authResponse encoding:NSASCIIStringEncoding];
		NSLog( @"auth response: %@", responseBody );
		[responseBody release];
		responseBody = nil;
		
		[connection release];
		
		// [ryan:5-31-10] testing out a way to get the user to confirm the extended permissions we want
		// temp hack, hardcode a url that we know works
//		NSString* responseURL = @"https://www.facebook.com/connect/uiserver.php?client_id=119908831367602&redirect_uri=http%3A%2F%2Foauth.twoalex.com%2F&scope=publish_stream%2Cread_stream&display=page&next=https%3A%2F%2Fgraph.facebook.com%2Foauth%2Fauthorize_success%3Fclient_id%3D119908831367602%26redirect_uri%3Dhttp%253A%252F%252Foauth.twoalex.com%252F%26scope%3Dpublish_stream%252Cread_stream%26type%3Dweb_server&cancel_url=https%3A%2F%2Fgraph.facebook.com%2Foauth%2Fauthorize_cancel%3Fclient_id%3D119908831367602%26redirect_uri%3Dhttp%253A%252F%252Foauth.twoalex.com%252F%26scope%3Dpublish_stream%252Cread_stream%26type%3Dweb_server&fbconnect=1&return_session=1&app_id=119908831367602&method=permissions.request&perms=publish_stream%2Cread_stream";
//		[self confirmExtendedPermissions:responseURL];

		// if we have a code, great, we exchange it for an access_token and we're done
		if ( nil != self._codeString )
		{
			[self loadAccessToken];		
		}
		else
		{
			// if not, we open up another dialog with the permissions confirmation
			self._permissionDialog = [[FBDataDialog alloc] initWithSession:self._session];
			self._permissionDialog._webPageData = self._authResponse;
//			self._permissionDialog.delegate = self;
			[self._permissionDialog show];
		}
	}
	else if ( connection == self._accessTokenConnection )
	{
		NSLog( @"connectionDidFinishLoading._token" );
		NSString* responseBody = [[NSString alloc] initWithData:self._accessTokenResponse encoding:NSASCIIStringEncoding];
		NSLog( @"token response: %@", responseBody );
		
		// the entire response body is just access_token=xxx, the access token is the goods that we're doing all this for. example is:
		// access_token=119908831367602|674667c45691cbca6a03d480-1394987957|dRiaWMp7ZoqrRy_jHDEutHC5AP0.
		
		NSArray* splitStrings = [responseBody componentsSeparatedByString:@"access_token="];
		
		if ( [splitStrings count] > 1 )
		{
			self._oAuthAccessToken = [splitStrings objectAtIndex:1];
			NSLog( @"accessToken = [%@]", self._oAuthAccessToken );
			[FacebookProxy updateDefaults];
			[self finishedAuthorizing];
		}
		else
		{
			NSLog( @"something is wrong with the access_code response: %@", responseBody );
//			assert( false );
		}
		
		[responseBody release];
		responseBody = nil;
		
		[connection release];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ( connection == self._authConnection )
	{
		NSLog( @"_auth connectionDidFail" );
	}
	else if ( connection == self._accessTokenConnection )
	{
		NSLog( @"_token connectionDidFail" );
	}
	
	// release the connection, and the data object
	[connection release];
	self._authResponse = nil;
// todo - manage this memory in a way that makes sense
//	// receivedData is declared as a method instance elsewhere
//	[receivedData release];
	
	// inform the user
	NSLog(@"Connection failed! Error - %@ %@",
				[error localizedDescription],
				[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

//#pragma mark -
//#pragma mark UIWebViewDelegate methods
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
// navigationType:(UIWebViewNavigationType)navigationType 
//{
//  NSURL* url = request.URL;
//	NSString* urlString = url.absoluteString;
//	
//	NSArray* splitStrings = [urlString componentsSeparatedByString:@"code="];
//	
//	if ( [splitStrings count] > 1 )
//	{
//		self._codeString = [splitStrings objectAtIndex:1];
//		NSLog( @"codeString = [%@] close down the web view", self._codeString );
//		[self._permissionDialog dismissWithSuccess:YES animated:YES];
//		[self loadAccessToken];
//	}	
////  if ([url.scheme isEqualToString:@"fbconnect"]) 
////	{
////    if ([url.resourceSpecifier isEqualToString:@"cancel"]) 
////		{
////      [self._loginDialog dismissWithSuccess:NO animated:YES];
////    } else {
////      [self._loginDialog dialogDidSucceed:url];
////    }
////    return NO;
////  } 
////	else if ([_loadingURL isEqual:url]) 
////	{
////    return YES;
////  } 
//	else if (navigationType == UIWebViewNavigationTypeLinkClicked) 
//	{    
//    [[UIApplication sharedApplication] openURL:request.URL];
//    return NO;
//  } 
////	else 
////	{
//    return YES;
////  }
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView 
//{
////  [_spinner stopAnimating];
////  _spinner.hidden = YES;
////  
////  self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
////  [self updateWebOrientation];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
//{
//  // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
//  if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) 
//	{
//    [self._loginDialog dismissWithError:error animated:YES];
//  }
//}


#pragma mark -
#pragma mark Public Instance Methods

// the event flow of this class is:
// 1. first, check if we already have an access token.  if so, gtfo.  if not..the normal flow is...
// 2. login (if not already logged in) via traditional login api
// 3. authorize using graph api, if we don't already have an oAuthAccessToken

-(void)loginAndAuthorizeWithTarget:(id)target callback:(SEL)authCallback
{
	self._authTarget = target;
	self._authCallback = authCallback;

	if ( [self isAuthorized] )
	{
		[self finishedAuthorizing];
	}
	else if ( ![self isLoggedin] )
	{
		[self login];
	}
	else
	{
		[self authorize];
	}
}

-(void)forgetToken
{
	self._oAuthAccessToken = nil;
	[FacebookProxy updateDefaults];
}

-(void)logout
{
	self._uid = 0;
	[self forgetToken];
	[_session logout];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"completedFacebookLogout" object:nil];

}

-(GraphAPI*)newGraph
{
	GraphAPI* n_graph = nil;
	
	if ( nil != self._oAuthAccessToken )
	{
		n_graph = [[GraphAPI alloc] initWithAccessToken:self._oAuthAccessToken];
	}
	
	return n_graph;
}

//#pragma mark Event Handlers
//#pragma mark Button Handlers

-(void)doneAuthorizing
{
	DLog(@"accessToken=%@",[FacebookProxy instance]._oAuthAccessToken);
	
	if ( nil == _meGraph )
		_meGraph = [self newGraph];
	
	_me = [_meGraph getObject:@"me"];
	//NSString* name = [_me name];
	//	
	NSArray* metadata = [_meGraph getConnectionTypesForObject:@"me"];
	//	
	NSLog( @"connection types = %@", metadata );
	UIImage *pic = [_meGraph getProfilePhotoForObject:@"me"];
	self.profilePic = pic;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"completedFacebookLogin" object:nil];

	
	//	NSString* likesText = [self._graph getConnections:@"likes" forObject:@"me"];
	//	NSString* searchText = [self._graph searchTerms:@"context" objectType:kSearchUsers];
	
	// this doesn't seem to work at all
	//	NSString* searchNewsText = [self._graph searchNewsFeedForUser:@"me" searchTerms:@"mother"];
	
	//	self._fullText.text = [NSString stringWithFormat:@"%@ Likes\n%@\n\nObject\n%@", name, likesText, self._fullText.text];
	//	self._fullText.text = [NSString stringWithFormat:@"%@ Likes\n%@\n\nObject\n%@\n\nSearch\n%@", name, likesText, self._fullText.text, searchText];
	//	self._fullText.text = [NSString stringWithFormat:@"Likes\n%@\n\nObject\n%@\n\nSearch\n%@\n\nNews for mother\n%@", likesText, self._fullText.text, searchText, searchNewsText];
	
	
}

+(NSDateFormatter*)fbDateFormatter{
		if (fbDate == NULL)
		{
			fbDate = [[NSDateFormatter alloc] init];
			[fbDate setTimeStyle:NSDateFormatterFullStyle];
			[fbDate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
		}
	return fbDate;
}

+(NSDateFormatter*)fbEventSectionFormatter{
	if (fbEventSectionFmt == NULL)
	{
		fbEventSectionFmt = [[NSDateFormatter alloc] init];
		[fbEventSectionFmt setTimeStyle:NSDateFormatterNoStyle];
		//[fbEventSectionFmt setDateStyle:NSDateFormatterMediumStyle];
		[fbEventSectionFmt setDateFormat:@"MMMM d"];
	}
	return fbEventSectionFmt;
}

+(NSDateFormatter*)fbEventCellTimeFormatter{
	if (fbEventCellTime == NULL)
	{
		fbEventCellTime = [[NSDateFormatter alloc] init];
		[fbEventCellTime setDateStyle:NSDateFormatterNoStyle];
		[fbEventCellTime setPMSymbol:@"p"];
		[fbEventCellTime setAMSymbol:@"a"];
		[fbEventCellTime setDateFormat:@"h:mma"];
	}
	return fbEventCellTime;
}

+(NSDateFormatter*)fbEventDetailMonthFormatter{
	if (fbEventDetailMonth == NULL)
	{
		fbEventDetailMonth = [[NSDateFormatter alloc] init];
		[fbEventDetailMonth setTimeStyle:NSDateFormatterNoStyle];
		[fbEventDetailMonth setDateFormat:@"MMM"];
	}
	return fbEventDetailMonth;
}
+(NSDateFormatter*)fbEventDetailDateFormatter{
	if (fbEventDetailDate == NULL)
	{
		fbEventDetailDate = [[NSDateFormatter alloc] init];
		[fbEventDetailDate setTimeStyle:NSDateFormatterNoStyle];
		[fbEventDetailDate setDateFormat:@"d"];
	}
	return fbEventDetailDate;
}

#pragma mark Button Handlers

-(void)doAuth
{
	//self._statusInfo.text = @"authorizing...";
	[[FacebookProxy instance] loginAndAuthorizeWithTarget:self callback:@selector(doneAuthorizing)];
}

-(NSArray*)refreshHome{
	if (_meGraph==nil) {
		_meGraph = [self newGraph];
	}
	return [_meGraph newsFeed:@"me"];
}

-(NSArray*)refreshEvents{
	if (_meGraph==nil) {
		_meGraph = [self newGraph];
	}
	return [_meGraph eventsFeed:@"me"];
}

-(void)storeProfilePic{
	GraphAPI *graph = [self newGraph];
	UIImage *pic = [graph getProfilePhotoForObject:@"me"];
	self.profilePic = pic;
	[graph release];
}

-(NSString*)findSuitableText:(NSDictionary*)fbItem {
	NSString *message = [fbItem objectForKey:@"message"];
	NSDictionary *attachment = [fbItem objectForKey:@"attachment"];
	NSMutableString *suitable = [NSMutableString stringWithString:@""];
	if (attachment == nil) {
		//there was no attachment so this is simply a status update
		if (message!=nil) {
			[suitable appendString:message];
		}
	} else{
		if (message!=nil) {
			[suitable appendString:message];
		}
		NSString *name = [attachment objectForKey:@"name"];
		if(name!=nil){
			[suitable appendFormat:@" %@",name];
		}
		NSString *caption = [attachment objectForKey:@"caption"];
		if (caption!=nil) {
			[suitable appendFormat:@" %@",caption];
		}
	}
	NSString *result = [suitable stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"]; 
	return result;
}

-(BOOL)doesHavePhoto:(NSDictionary*)fbItem{
	NSDictionary *attachment = [fbItem objectForKey:@"attachment"];
	if (attachment) {
		NSArray *media  = [attachment objectForKey:@"media"];
		if (media) {
			if ([media isKindOfClass:[NSArray class]]) {
				if ([media count]>0) {
					NSDictionary *item = [media objectAtIndex:0];
					NSString *type = [item objectForKey:@"type"];
					if ([type isEqualToString:@"photo"]) {
						return YES;
					}else {
						return NO;
					}
				}else {
					return NO;
				}
				
			}else {
				return NO;
			}
			
		}else {
			return NO;
		}
	}else {
		return NO;
	}
	
}

-(NSString*)imageUrlForPhoto:(NSDictionary*)fbItem{
	NSDictionary *attachment = [fbItem objectForKey:@"attachment"];
	if (attachment) {
		NSArray *media  = [attachment objectForKey:@"media"];
		if (media) {
			if ([media isKindOfClass:[NSArray class]]) {
				if ([media count]>0) {
					NSDictionary *item = [media objectAtIndex:0];
					NSString *type = [item objectForKey:@"type"];
					if ([type isEqualToString:@"photo"]) {
						return [item objectForKey:@"src"];
					}else {
						return nil;
					}
				}else {
					return nil;
				}
				
			}else {
				return nil;
			}
			
		}else {
			return nil;
		}
	}else {
		return nil;
	}

}

-(NSString*)albumIdForPhoto:(NSDictionary*)fbItem{
	NSDictionary *attachment = [fbItem objectForKey:@"attachment"];
	if (attachment) {
		NSArray *media  = [attachment objectForKey:@"media"];
		if (media) {
			if ([media isKindOfClass:[NSArray class]]) {
				if ([media count]>0) {
					NSDictionary *item = [media objectAtIndex:0];
					NSString *type = [item objectForKey:@"type"];
					if ([type isEqualToString:@"photo"]) {
						NSDictionary *photo = [item objectForKey:@"photo"];
						if ([photo isKindOfClass:[NSDictionary class]]) {
							return [photo objectForKey:@"aid"];
						}else {
							return nil;
						}

					}else {
						return nil;
					}
				}else {
					return nil;
				}
				
			}else {
				return nil;
			}
			
		}else {
			return nil;
		}
	}else {
		return nil;
	}
	
}


-(NSString*)userNameFrom:(NSNumber*)_id{
	NSDictionary *profile = [profileLookup objectForKey:[_id stringValue]];
	return [profile objectForKey:@"name"];
}
-(NSString*)profilePicUrlFrom:(NSNumber*)_id{
	NSDictionary *profile = [profileLookup objectForKey:[_id stringValue]];
	return [profile objectForKey:@"pic_square"];
}
-(void)cacheIncomingProfiles:(NSArray*)profiles{
	@synchronized(profileLookup){
		for (NSDictionary*p in profiles){
			NSNumber *id = [p objectForKey:@"id"];
			if (id==nil) {
				id = [p objectForKey:@"uid"];
			}
			if (id!=nil) {
				NSDictionary *exists = [profileLookup objectForKey:[id stringValue]];
				if (exists==nil) {
					[profileLookup setObject:p forKey:[id stringValue]];
				}
			}
			
		}
	}
}
-(void)cacheIncomingAlbums:(NSArray*)albums{
	@synchronized(albumLookup){
		for (NSDictionary*a in albums){
			NSNumber *id = [a objectForKey:@"aid"];
			if (id!=nil) {
				NSDictionary *exists = [albumLookup objectForKey:[id stringValue]];
				if (exists==nil) {
					[albumLookup setObject:a forKey:[id stringValue]];
				}
			}
			
		}
	}
}
-(NSString*)albumNameFrom:(NSString*)_id{
	NSDictionary *album = [albumLookup objectForKey:_id];
	return [album objectForKey:@"name"];
}

@end
