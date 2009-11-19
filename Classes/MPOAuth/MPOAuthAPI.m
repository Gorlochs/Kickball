//
//  MPOAuthAPI.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthAPI.h"
#import "MPDebug.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPURLRequestParameter.h"

#import "NSURL+MPURLParameterAdditions.h"
#import "MPOAuthAPI+KeychainAdditions.h"

#define kMPOAuthTokenRefreshDateDefaultsKey			@"MPOAuthAutomaticTokenRefreshLastExpiryDate"

NSString *kMPOAuthCredentialConsumerKey				= @"kMPOAuthCredentialConsumerKey";
NSString *kMPOAuthCredentialConsumerSecret			= @"kMPOAuthCredentialConsumerSecret";
NSString *kMPOAuthCredentialRequestToken			= @"kMPOAuthCredentialRequestToken";
NSString *kMPOAuthCredentialRequestTokenSecret		= @"kMPOAuthCredentialRequestTokenSecret";
NSString *kMPOAuthCredentialAccessToken				= @"kMPOAuthCredentialAccessToken";
NSString *kMPOAuthCredentialAccessTokenSecret		= @"kMPOAuthCredentialAccessTokenSecret";
NSString *kMPOAuthCredentialSessionHandle			= @"kMPOAuthCredentialSessionHandle";

NSString *kMPOAuthSignatureMethod					= @"kMPOAuthSignatureMethod";

NSString *MPOAuthRequestTokenURLKey					= @"MPOAuthRequestTokenURL";
NSString *MPOAuthUserAuthorizationURLKey			= @"MPOAuthUserAuthorizationURL";
NSString *MPOAuthUserAuthorizationMobileURLKey		= @"MPOAuthUserAuthorizationMobileURL";
NSString *MPOAuthAccessTokenURLKey					= @"MPOAuthAccessTokenURL";

NSString *MPOAuthCredentialRequestTokenKey			= @"oauth_token_request";
NSString *MPOAuthCredentialRequestTokenSecretKey	= @"oauth_token_request_secret";
NSString *MPOAuthCredentialAccessTokenKey			= @"oauth_token_access";
NSString *MPOAuthCredentialAccessTokenSecretKey		= @"oauth_token_access_secret";
NSString *MPOAuthCredentialSessionHandleKey			= @"oauth_session_handle";
NSString *fsUsername			= nil;
NSString *fsPassword			= nil;

@interface MPOAuthAPI ()
@property (nonatomic, readwrite, retain) NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *credentials;
@property (nonatomic, readwrite, retain) NSURL *authenticationURL;
@property (nonatomic, readwrite, retain) NSURL *baseURL;
@property (nonatomic, readwrite, retain) NSMutableArray *activeLoaders;
@property (nonatomic, readwrite, retain) NSTimer *refreshTimer;
@property (nonatomic, readwrite, assign) MPOAuthAuthenticationState authenticationState;

- (void)_initAuthorizationEndpointsForURL:(NSURL *)inBaseURL;
- (void)_authenticationRequestForRequestToken;
- (void)_authenticationRequestForAuthExchange;

- (void)_authenticationRequestForUserPermissionsConfirmationAtURL:(NSURL *)inURL;
- (void)_authenticationRequestForAccessToken;
- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer;

@end

@implementation MPOAuthAPI

- (id)initWithCredentials:(NSDictionary *)inCredentials andBaseURL:(NSURL *)inBaseURL {
	return [self initWithCredentials:inCredentials authenticationURL:inBaseURL andBaseURL:inBaseURL];
}

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL fsUsername:(NSString *) fsUser fsPassword:(NSString *) fsPass{
	
	fsUsername = fsUser;
	fsPassword = fsPass;
	
	if (self = [super init]) {
		self.authenticationURL = inAuthURL;
		self.baseURL = inBaseURL;
		self.authenticationState = MPOAuthAuthenticationStateUnauthenticated;
		
		// load authorization endpoints from file
		[self _initAuthorizationEndpointsForURL:inAuthURL];
		
		NSString *requestToken = [self findValueFromKeychainUsingName:MPOAuthCredentialRequestTokenKey];
		NSString *requestTokenSecret = [self findValueFromKeychainUsingName:MPOAuthCredentialRequestTokenSecretKey];
		NSString *accessToken = [self findValueFromKeychainUsingName:MPOAuthCredentialAccessTokenKey];
		NSString *accessTokenSecret = [self findValueFromKeychainUsingName:MPOAuthCredentialAccessTokenSecretKey];
		NSString *sessionHandle = [self findValueFromKeychainUsingName:MPOAuthCredentialSessionHandleKey];
		
		_credentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:inCredentials];
		[_credentials setRequestToken:requestToken];
		[_credentials setRequestTokenSecret:requestTokenSecret];
		[(MPOAuthCredentialConcreteStore *)_credentials setAccessToken:accessToken];
		[_credentials setAccessTokenSecret:accessTokenSecret];
		[_credentials setSessionHandle:sessionHandle];
		
		_activeLoaders = [[NSMutableArray alloc] initWithCapacity:10];
		
		self.signatureScheme = MPOAuthSignatureSchemeHMACSHA1;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestTokenRejected:) name:MPOAuthNotificationRequestTokenRejected object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];		
		if(accessToken == nil)
		[self _authenticationRequestForAuthExchange];
	}
	
	return self;

}

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL {
	if (self = [super init]) {
		self.authenticationURL = inAuthURL;
		self.baseURL = inBaseURL;
		self.authenticationState = MPOAuthAuthenticationStateUnauthenticated;
		
		// load authorization endpoints from file
		[self _initAuthorizationEndpointsForURL:inAuthURL];
		
		NSString *requestToken = [self findValueFromKeychainUsingName:MPOAuthCredentialRequestTokenKey];
		NSString *requestTokenSecret = [self findValueFromKeychainUsingName:MPOAuthCredentialRequestTokenSecretKey];
		NSString *accessToken = [self findValueFromKeychainUsingName:MPOAuthCredentialAccessTokenKey];
		NSString *accessTokenSecret = [self findValueFromKeychainUsingName:MPOAuthCredentialAccessTokenSecretKey];
		NSString *sessionHandle = [self findValueFromKeychainUsingName:MPOAuthCredentialSessionHandleKey];
		
		_credentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:inCredentials];
		[_credentials setRequestToken:requestToken];
		[_credentials setRequestTokenSecret:requestTokenSecret];
		[(MPOAuthCredentialConcreteStore *)_credentials setAccessToken:accessToken];
		[_credentials setAccessTokenSecret:accessTokenSecret];
		[_credentials setSessionHandle:sessionHandle];
		
		_activeLoaders = [[NSMutableArray alloc] initWithCapacity:10];
		
		self.signatureScheme = MPOAuthSignatureSchemeHMACSHA1;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestTokenRejected:) name:MPOAuthNotificationRequestTokenRejected object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];		
		
		[self authenticate];
	}
	return self;	
}

- (void)_initAuthorizationEndpointsForURL:(NSURL *)inBaseURL {
	NSString *oauthEndpointsConfigPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"oauthAutoConfig" ofType:@"plist"];
	NSDictionary *oauthEndpointsDictionary = [NSDictionary dictionaryWithContentsOfFile:oauthEndpointsConfigPath];
	
	for ( NSString *domainString in [oauthEndpointsDictionary keyEnumerator]) {
		if ([inBaseURL domainMatches:domainString]) {
			NSDictionary *oauthEndpoints = [oauthEndpointsDictionary objectForKey:domainString];
			NSAssert( [oauthEndpoints count] >= 3, @"Incorrect number of oauth authorization methods");
			
			self.oauthRequestTokenURL = [NSURL URLWithString:[oauthEndpoints objectForKey:MPOAuthRequestTokenURLKey]];
			self.oauthAuthorizeTokenURL = [NSURL URLWithString:[oauthEndpoints objectForKey:MPOAuthUserAuthorizationURLKey]];
			self.oauthGetAccessTokenURL = [NSURL URLWithString:[oauthEndpoints objectForKey:MPOAuthAccessTokenURLKey]];

			break;
		}
	}
}

- (oneway void)dealloc {
	self.credentials = nil;
	self.baseURL = nil;
	self.authenticationURL = nil;
	self.oauthRequestTokenURL = nil;
	self.oauthAuthorizeTokenURL = nil;
	self.oauthGetAccessTokenURL = nil;
	self.activeLoaders = nil;
	
	[self.refreshTimer invalidate];
	self.refreshTimer = nil;
	
	[super dealloc];
}

@synthesize credentials = _credentials;
@synthesize baseURL = _baseURL;
@synthesize authenticationURL = _authenticationURL;
@synthesize oauthRequestTokenURL = _oauthRequestTokenURL;
@synthesize oauthAuthorizeTokenURL = _oauthAuthorizeTokenURL;
@synthesize oauthGetAccessTokenURL = _oauthGetAccessTokenURL;
@synthesize signatureScheme = _signatureScheme;
@synthesize activeLoaders = _activeLoaders;
@synthesize delegate = _delegate;
@synthesize refreshTimer = _refreshTimer;
@synthesize authenticationState = _oauthAuthenticationState;

#pragma mark -

- (void)setSignatureScheme:(MPOAuthSignatureScheme)inScheme {
	_signatureScheme = inScheme;
	
	NSString *methodString = @"HMAC-SHA1";
	
	switch (_signatureScheme) {
		case MPOAuthSignatureSchemePlainText:
			methodString = @"PLAINTEXT";
			break;
		case MPOAuthSignatureSchemeRSASHA1:
			methodString = @"RSA-SHA1";
		case MPOAuthSignatureSchemeHMACSHA1:
		default:
			// already initted to the default
			break;
	}
	
	_credentials.signatureMethod = methodString;
}

#pragma mark -

- (void)authenticate {
	NSAssert(_credentials.consumerKey, @"A Consumer Key is required for use of OAuth.");
	if (!_credentials.accessToken && !_credentials.requestToken) {
		[self _authenticationRequestForRequestToken];
	} else if (!_credentials.accessToken) {
		[self _authenticationRequestForAccessToken];
	} else if (_credentials.accessToken) {
		NSTimeInterval expiryDateInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kMPOAuthTokenRefreshDateDefaultsKey];
		NSDate *tokenExpiryDate = [NSDate dateWithTimeIntervalSinceReferenceDate:expiryDateInterval];
		
		if ([tokenExpiryDate compare:[NSDate date]] == NSOrderedAscending) {
			[self _automaticallyRefreshAccessToken:nil];
		}
	}
}

- (BOOL)isAuthenticated {
	return (self.authenticationState == MPOAuthAuthenticationStateAuthenticated);
}

- (void)_authenticationRequestForAuthExchange {
	self.authenticationState = MPOAuthAuthenticationStateRequestRequestToken;
	NSMutableArray * tempMute = [[NSMutableArray alloc] initWithCapacity:1];		

	if(fsUsername && fsPassword){
		[tempMute addObject:[[MPURLRequestParameter alloc] initWithName:@"fs_username" andValue:fsUsername]];
		[tempMute addObject:[[MPURLRequestParameter alloc] initWithName:@"fs_password" andValue:fsPassword]];
	} else {
		tempMute = nil;
	}
	
	[self performMethod:nil atURL:self.oauthAuthorizeTokenURL withParameters:tempMute withTarget:self andAction:@selector(_authenticationRequestForRequestTokenSuccessfulLoad:withData:)];
}

- (void)_authenticationRequestForRequestToken {
	if (self.oauthRequestTokenURL) {
		MPLog(@"--> Performing Request Token Request: %@", self.oauthRequestTokenURL);
		self.authenticationState = MPOAuthAuthenticationStateRequestRequestToken;
		[self performMethod:nil atURL:self.oauthRequestTokenURL withParameters:nil withTarget:self andAction:@selector(_authenticationRequestForRequestTokenSuccessfulLoad:withData:)];
	}
}


- (void)_authenticationRequestForRequestTokenSuccessfulLoad:(MPOAuthAPIRequestLoader *)inLoader withData:(NSData *)inData {
	NSDictionary *oauthResponseParameters = inLoader.oauthResponse.oauthParameters;
	NSString *xoauthRequestAuthURL = [oauthResponseParameters objectForKey:@"xoauth_request_auth_url"]; // a common custom extension, used by Yahoo!
	NSURL *userAuthURL = xoauthRequestAuthURL ? [NSURL URLWithString:xoauthRequestAuthURL] : self.oauthAuthorizeTokenURL;
	NSURL *callbackURL = [self.delegate respondsToSelector:@selector(callbackURLForCompletedUserAuthorization)] ? [self.delegate callbackURLForCompletedUserAuthorization] : nil;
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:	[oauthResponseParameters objectForKey:@"oauth_token"], @"oauth_token",
																			callbackURL, @"oauth_callback",
																			nil];

	userAuthURL = [userAuthURL urlByAddingParameterDictionary:parameters];
	BOOL delegateWantsToBeInvolved = [self.delegate respondsToSelector:@selector(automaticallyRequestAuthenticationFromURL:withCallbackURL:)];

	if (!delegateWantsToBeInvolved || (delegateWantsToBeInvolved && [self.delegate automaticallyRequestAuthenticationFromURL:userAuthURL withCallbackURL:callbackURL])) {
		MPLog(@"--> Automatically Performing User Auth Request: %@", userAuthURL);
		self.authenticationState = MPOAuthAuthenticationStateRequestUserAccess;
		[self _authenticationRequestForUserPermissionsConfirmationAtURL:userAuthURL];
	}
}

- (void)_authenticationRequestForUserPermissionsConfirmationAtURL:(NSURL *)userAuthURL {
#ifndef TARGET_OS_IPHONE
	//[[NSWorkspace sharedWorkspace] openURL:userAuthURL];
#else
	//[[UIApplication sharedApplication] openURL:userAuthURL];
#endif
}

- (void)_authenticationRequestForAccessToken {
	if (self.oauthGetAccessTokenURL) {
		MPLog(@"--> Performing Access Token Request: %@", self.oauthGetAccessTokenURL);
		self.authenticationState = MPOAuthAuthenticationStateRequestAccessToken;
		[self performMethod:nil atURL:self.oauthGetAccessTokenURL withParameters:nil withTarget:self andAction:nil];
	}
}

#pragma mark -
- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget withParameters:(NSArray *)inParameters andAction:(SEL)inAction {
	[self performMethod:inMethod atURL:self.baseURL withParameters:inParameters withTarget:inTarget andAction:inAction];

}

- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget andAction:(SEL)inAction {
	[self performMethod:inMethod atURL:self.baseURL withParameters:nil withTarget:inTarget andAction:inAction];
}

//- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction {
//	if (!inMethod && ![inURL path] && ![inURL query]) {
//		[NSException raise:@"MPOAuthNilMethodRequestException" format:@"Nil was passed as the method to be performed on %@", inURL];
//	}
//	
//	NSURL *requestURL = inMethod ? [NSURL URLWithString:inMethod relativeToURL:inURL] : inURL;
//
//	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters];
//	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
//
//	loader.credentials = self.credentials;
//	loader.target = inTarget;
//	loader.action = inAction ? inAction : @selector(_performedLoad:receivingData:);
//	
//	[loader loadSynchronously:NO];
////	[self.activeLoaders addObject:loader];
//
//	[loader release];
//	[aRequest release];
//}

///////////
- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget withParameters:(NSArray *)inParameters andAction:(SEL)inAction doPost:(BOOL)inPost { 
    [self performMethod:inMethod atURL:self.baseURL withParameters:inParameters withTarget:inTarget andAction:inAction doPost:inPost]; 
}

- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget andAction:(SEL)inAction doPost:(BOOL)inPost { 
    [self performMethod:inMethod atURL:self.baseURL withParameters:nil withTarget:inTarget andAction:inAction doPost:inPost]; 
} 

- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction { 
    [self performMethod:inMethod atURL:inURL withParameters:inParameters withTarget:inTarget andAction:inAction doPost:NO]; 
} 

- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction doPost:(BOOL)inPost { 
    if (!inMethod && ![inURL path] && ![inURL query]) { 
        [NSException raise:@"MPOAuthNilMethodRequestException" format:@"Nil was passed as the method to be performed on %@", inURL]; 
    } 
    NSURL *requestURL = inMethod ? [NSURL URLWithString:inMethod relativeToURL:inURL] : inURL; 
    MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters]; 
    if (inPost) {
        aRequest.HTTPMethod = @"POST";
    }
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
    
	loader.credentials = self.credentials;
	loader.target = inTarget;
	loader.action = inAction ? inAction : @selector(_performedLoad:receivingData:);
	
	[loader loadSynchronously:NO];
    //	[self.activeLoaders addObject:loader];
    
	[loader release];
	[aRequest release];
}        
///////////
- (NSData *)dataForMethod:(NSString *)inMethod {
	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:nil];
}

- (NSData *)dataForMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:inParameters];
}

- (NSData *)dataForURL:(NSURL *)inURL andMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	NSURL *requestURL = [NSURL URLWithString:inMethod relativeToURL:inURL];
	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters];
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];

	loader.credentials = self.credentials;
	[loader loadSynchronously:NO];
	
	[loader autorelease];
	[aRequest release];
	
	return loader.data;
}

#pragma mark -

- (void)discardServerCredentials {
	[self removeValueFromKeychainUsingName:MPOAuthCredentialRequestTokenKey];
	[self removeValueFromKeychainUsingName:MPOAuthCredentialRequestTokenSecretKey];	
	[self removeValueFromKeychainUsingName:MPOAuthCredentialAccessTokenKey];
	[self removeValueFromKeychainUsingName:MPOAuthCredentialAccessTokenSecretKey];	

	[_credentials setRequestToken:nil];
	[_credentials setRequestTokenSecret:nil];
	[_credentials setAccessToken:nil];
	[_credentials setAccessTokenSecret:nil];
	[_credentials setSessionHandle:nil];
	
	self.authenticationState = MPOAuthAuthenticationStateUnauthenticated;
}

#pragma mark -
#pragma mark - Private APIs -

- (void)_performedLoad:(MPOAuthAPIRequestLoader *)inLoader receivingData:(NSData *)inData {
	NSLog(@"loaded %@, and got %@", inLoader, inData);
}

#pragma mark -

- (void)_requestTokenReceived:(NSNotification *)inNotification {
	[self addToKeychainUsingName:MPOAuthCredentialRequestTokenKey andValue:[[inNotification userInfo] objectForKey:@"oauth_token"]];
	[self addToKeychainUsingName:MPOAuthCredentialRequestTokenSecretKey andValue:[[inNotification userInfo] objectForKey:@"oauth_token_secret"]];
}

- (void)_requestTokenRejected:(NSNotification *)inNotification {
	[self removeValueFromKeychainUsingName:MPOAuthCredentialRequestTokenKey];
	[self removeValueFromKeychainUsingName:MPOAuthCredentialRequestTokenSecretKey];	
}

- (void)_accessTokenReceived:(NSNotification *)inNotification {
	[self removeValueFromKeychainUsingName:MPOAuthCredentialRequestTokenKey];
	[self removeValueFromKeychainUsingName:MPOAuthCredentialRequestTokenSecretKey];
	
	[self addToKeychainUsingName:MPOAuthCredentialAccessTokenKey andValue:[[inNotification userInfo] objectForKey:@"oauth_token"]];
	[self addToKeychainUsingName:MPOAuthCredentialAccessTokenSecretKey andValue:[[inNotification userInfo] objectForKey:@"oauth_token_secret"]];
	
	if ([[inNotification userInfo] objectForKey:MPOAuthCredentialSessionHandleKey]) {
		[self addToKeychainUsingName:MPOAuthCredentialSessionHandleKey andValue:[[inNotification userInfo] objectForKey:MPOAuthCredentialSessionHandleKey]];
	}
	
	self.authenticationState = MPOAuthAuthenticationStateAuthenticated;
	
	NSTimeInterval tokenRefreshInterval = (NSTimeInterval)[[[inNotification userInfo] objectForKey:@"oauth_expires_in"] intValue];
	NSDate *tokenExpiryDate = [NSDate dateWithTimeIntervalSinceNow:tokenRefreshInterval];
	[[NSUserDefaults standardUserDefaults] setDouble:[tokenExpiryDate timeIntervalSinceReferenceDate] forKey:kMPOAuthTokenRefreshDateDefaultsKey];

	NSString *requestToken = [self findValueFromKeychainUsingName:MPOAuthCredentialRequestTokenKey];
	NSString *requestTokenSecret = [self findValueFromKeychainUsingName:MPOAuthCredentialRequestTokenSecretKey];
	NSString *accessToken = [self findValueFromKeychainUsingName:MPOAuthCredentialAccessTokenKey];
	NSString *accessTokenSecret = [self findValueFromKeychainUsingName:MPOAuthCredentialAccessTokenSecretKey];
	NSString *sessionHandle = [self findValueFromKeychainUsingName:MPOAuthCredentialSessionHandleKey];
	
	[_credentials setRequestToken:requestToken];
	[_credentials setRequestTokenSecret:requestTokenSecret];
	[(MPOAuthCredentialConcreteStore *)_credentials setAccessToken:accessToken];
	[_credentials setAccessTokenSecret:accessTokenSecret];
	[_credentials setSessionHandle:sessionHandle];
	
	if (!_refreshTimer && tokenRefreshInterval > 0.0) {
		self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:tokenRefreshInterval target:self selector:@selector(_automaticallyRefreshAccessToken:) userInfo:nil repeats:YES];
	}
}

#pragma mark -

- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer {
	MPURLRequestParameter *sessionHandleParameter = nil;
	if (_credentials.sessionHandle) {
		sessionHandleParameter = [[MPURLRequestParameter alloc] init];
		sessionHandleParameter.name = @"oauth_session_handle";
		sessionHandleParameter.value = _credentials.sessionHandle;
	}
	
	self.authenticationState = MPOAuthAuthenticationStateRequestAccessToken;
	
	[self performMethod:nil
				  atURL:self.oauthGetAccessTokenURL
		 withParameters:sessionHandleParameter ? [NSArray arrayWithObject:sessionHandleParameter] : nil
			 withTarget:nil
			  andAction:nil];
	
	[sessionHandleParameter release];
}

@end
