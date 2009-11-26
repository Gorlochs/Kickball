//
//  MPOAuthAPIRequestLoader.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPOAuthConnection.h"
#import "MPOAuthCredentialStore.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"
#import "NSURLResponse+Encoding.h"
#import "MPDebug.h"

NSString *MPOAuthNotificationRequestTokenReceived	= @"MPOAuthNotificationRequestTokenReceived";
NSString *MPOAuthNotificationRequestTokenRejected	= @"MPOAuthNotificationRequestTokenRejected";
NSString *MPOAuthNotificationAccessTokenReceived	= @"MPOAuthNotificationAccessTokenReceived";
NSString *MPOAuthNotificationAccessTokenRejected	= @"MPOAuthNotificationAccessTokenRejected";
NSString *MPOAuthNotificationAccessTokenRefreshed	= @"MPOAuthNotificationAccessTokenRefreshed";
NSString *MPOAuthNotificationOAuthCredentialsReady	= @"MPOAuthNotificationOAuthCredentialsReady";
NSString *MPOAuthNotificationErrorHasOccurred		= @"MPOAuthNotificationErrorHasOccurred";

@interface MPOAuthURLResponse ()
@property (nonatomic, readwrite, retain) NSURLResponse *urlResponse;
@property (nonatomic, readwrite, retain) NSDictionary *oauthParameters;
@end


@interface MPOAuthAPIRequestLoader ()
@property (nonatomic, readwrite, retain) NSData *data;
@property (nonatomic, readwrite, retain) NSString *responseString;

- (void)_interrogateResponseForOAuthData;
@end

@protocol MPOAuthAPIInternalClient;

@implementation MPOAuthAPIRequestLoader

- (id)initWithURL:(NSURL *)inURL {
	return [self initWithRequest:[[[MPOAuthURLRequest alloc] initWithURL:inURL andParameters:nil] autorelease]];
}

- (id)initWithRequest:(MPOAuthURLRequest *)inRequest {
	if (self = [super init]) {
		self.oauthRequest = inRequest;
		_dataBuffer = [[NSMutableData alloc] init];
	}
	return self;
}

- (oneway void)dealloc {
	self.credentials = nil;
	self.oauthRequest = nil;
	self.oauthResponse = nil;
	self.data = nil;
	self.responseString = nil;

	[super dealloc];
}

@synthesize credentials = _credentials;
@synthesize oauthRequest = _oauthRequest;
@synthesize oauthResponse = _oauthResponse;
@synthesize data = _dataBuffer;
@synthesize responseString = _dataAsString;
@synthesize target = _target;
@synthesize action = _action;

#pragma mark -

- (MPOAuthURLResponse *)oauthResponse {
	if (!_oauthResponse) {
		_oauthResponse = [[MPOAuthURLResponse alloc] init];
	}
	
	return _oauthResponse;
}

- (NSString *)responseString {
	if (!_dataAsString) {
		_dataAsString = [[NSString alloc] initWithData:self.data encoding:[self.oauthResponse.urlResponse encoding]];
	}
	
	return _dataAsString;
}

- (void)loadSynchronously:(BOOL)inSynchronous {
	NSAssert(_credentials, @"Unable to load without valid credentials");
	NSAssert(_credentials.consumerKey, @"Unable to load, credentials contain no consumer key");
	if (!inSynchronous) {
		[MPOAuthConnection connectionWithRequest:self.oauthRequest delegate:self credentials:self.credentials];
	} else {
		MPOAuthURLResponse *theOAuthResponse = nil;
		self.data = [MPOAuthConnection sendSynchronousRequest:self.oauthRequest usingCredentials:self.credentials returningResponse:&theOAuthResponse error:nil];
		self.oauthResponse = theOAuthResponse;
		[self _interrogateResponseForOAuthData];
	}
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
		MPLog(@"%p: [%@ %@] %@, %@", self, NSStringFromClass([self class]), NSStringFromSelector(_cmd), connection, error);
		[_target performSelector:_action withObject:self withObject:self.data];	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.oauthResponse.urlResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	MPLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_dataBuffer appendData:data];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	MPLog( @"[%@ %@]: %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), request, redirectResponse);
	return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self _interrogateResponseForOAuthData];

	if (_action) {
		if ([_target conformsToProtocol:@protocol(MPOAuthAPIInternalClient)]) {
			[_target performSelector:_action withObject:self withObject:self.data];
		} else {
			[_target performSelector:_action withObject:self.oauthRequest.url withObject:self.responseString];
		}
	}
}

#pragma mark -

- (void)_interrogateResponseForOAuthData {
	NSString *response = self.responseString;
	NSString *mangleResponse = self.responseString;
	NSDictionary *foundParameters = nil;
	NSInteger status = [(NSHTTPURLResponse *)[self.oauthResponse urlResponse] statusCode];
	BOOL oauthResponseSuccess = ([response rangeOfString:@"oauth"].location != NSNotFound);
	BOOL oauthTokenSuccess = ([response rangeOfString:@"oauth_token" options:NSCaseInsensitiveSearch].location != NSNotFound);
	BOOL oauthError = ([response rangeOfString:@"<error>"].location != NSNotFound);
	oauthError = ([response rangeOfString:@"SIGNATURE_INVALID"].location != NSNotFound);	
	
	if ([response length] > 5 && oauthResponseSuccess && !oauthError) {
		mangleResponse = [mangleResponse stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" withString:@""];
		mangleResponse = [mangleResponse stringByReplacingOccurrencesOfString:@"<credentials><oauth_token>" withString:@"oauth_token="];
		mangleResponse = [mangleResponse stringByReplacingOccurrencesOfString:@"</oauth_token><oauth_token_secret>" withString:@"&oauth_token_secret="];
		mangleResponse = [mangleResponse stringByReplacingOccurrencesOfString:@"</oauth_token_secret></credentials>" withString:@""];
		mangleResponse = [mangleResponse stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		
		response = mangleResponse;
		foundParameters = [MPURLRequestParameter parameterDictionaryFromString:response];
		self.oauthResponse.oauthParameters = foundParameters;
		
		if (status == 401 || ([response length] > 13 && [[response substringToIndex:13] isEqualToString:@"oauth_problem"])) {
			NSString *aParameterValue = nil;
			MPLog(@"oauthProblem = %@", foundParameters);
			
			if ([foundParameters count] && (aParameterValue = [foundParameters objectForKey:@"oauth_problem"])) {
				if ([aParameterValue isEqualToString:@"token_rejected"]) {
					if (self.credentials.requestToken && !self.credentials.accessToken) {
						[_credentials setRequestToken:nil];
						[_credentials setRequestTokenSecret:nil];
						
						[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationRequestTokenRejected
																			object:nil
																		  userInfo:foundParameters];
					} else if (self.credentials.accessToken && !self.credentials.requestToken) {
						// your access token may be invalid due to a number of reasons so it's up to the
						// user to decide whether or not to remove them
						[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenRejected
																			object:nil
																		  userInfo:foundParameters];
						
					}
				}
			}
		} else if ([response length] > 11 && oauthTokenSuccess) {
			NSString *aParameterValue = nil;
			MPLog(@"foundParameters = %@", foundParameters);

			if ([foundParameters count] && (aParameterValue = [foundParameters objectForKey:@"oauth_token"])) {
				if (!self.credentials.requestToken && !self.credentials.accessToken) {
					[_credentials setAccessTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenReceived
																		object:nil
																	  userInfo:foundParameters];
					
				} else if (!self.credentials.accessToken && self.credentials.requestToken) {
					[_credentials setRequestToken:nil];
					[_credentials setRequestTokenSecret:nil];
					[_credentials setAccessToken:aParameterValue];
					[_credentials setAccessTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenReceived
																		object:nil
																	  userInfo:foundParameters];
					
				} else if (self.credentials.accessToken && !self.credentials.requestToken) {
					// replace the current token
					[_credentials setAccessToken:aParameterValue];
					[_credentials setAccessTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenRefreshed
																		object:nil
																	  userInfo:foundParameters];
				}
			}
		}
	}
}

@end
