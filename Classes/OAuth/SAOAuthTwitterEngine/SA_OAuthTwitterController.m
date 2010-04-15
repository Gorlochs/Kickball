//
//  SA_OAuthTwitterController.m
//
//  Created by Ben Gottlieb on 24 July 2009.
//  Copyright 2009 Stand Alone, Inc.
//
//  Some code and concepts taken from examples provided by 
//  Matt Gemmell, Chris Kimpton, and Isaiah Carew
//  See ReadMe for further attributions, copyrights and license info.
//

#import <UIKit/UIKit.h>

#import "SA_OAuthTwitterEngine.h"

#import "SA_OAuthTwitterController.h"

// Constants
//static NSString* const kGGTwitterLoadingBackgroundImage = @"twitter_load.png";

@interface DummyClassForProvidingSetDataDetectorTypesMethod
- (void) setDataDetectorTypes: (int) types;
- (void) setDetectsPhoneNumbers: (BOOL) detects;
@end

@implementation SA_OAuthTwitterController
@synthesize engine = _engine, delegate = _delegate, navigationBar = _navBar;


- (void) dealloc {
	[_backgroundView release];
	
//	_webView.delegate = nil;
//	[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @""]]];
//	[_webView release];
	
	[_activityIndicator release];
	_activityIndicator = nil;
	self.view = nil;
	self.engine = nil;
	[super dealloc];
}

+ (SA_OAuthTwitterController *) controllerToEnterCredentialsWithTwitterEngine: (XAuthTwitterEngine *) engine delegate: (id <SA_OAuthTwitterControllerDelegate>) delegate {
	//if (![self credentialEntryRequiredWithTwitterEngine: engine]) return nil;			//not needed
	
	SA_OAuthTwitterController					*controller = [[[SA_OAuthTwitterController alloc] initWithEngine: engine] autorelease];
	
	controller.delegate = delegate;
	return controller;
}

+ (BOOL) credentialEntryRequiredWithTwitterEngine: (SA_OAuthTwitterEngine *) engine {
	return ![engine isAuthorized];
}


- (id) initWithEngine: (XAuthTwitterEngine *) engine {
	if (self = [super init]) {
		self.engine = engine;

		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
		_activityIndicator.hidesWhenStopped = YES;

//		_webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, 320, 416)];
//		_webView.delegate = self;
//		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//		if ([_webView respondsToSelector: @selector(setDetectsPhoneNumbers:)]) [(id) _webView setDetectsPhoneNumbers: NO];
//		if ([_webView respondsToSelector: @selector(setDataDetectorTypes:)]) [(id) _webView setDataDetectorTypes: 0];
		
		//NSURLRequest			*request = _engine.authorizeURLRequest;
		
		//[_webView loadRequest: request];
	}
	return self;
}

//=============================================================================================================================
#pragma mark Actions
- (void) denied {
	if ([_delegate respondsToSelector: @selector(OAuthTwitterControllerFailed:)]) [_delegate OAuthTwitterControllerFailed: self];
	//[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) gotPin: (NSString *) pin {
	//_engine.pin = pin;
	[_engine requestAccessToken];
	
	//if ([_delegate respondsToSelector: @selector(OAuthTwitterController:authenticatedWithUsername:)]) [_delegate OAuthTwitterController: self authenticatedWithUsername: _engine.username];
    if ([_delegate respondsToSelector: @selector(OAuthTwitterController:authenticatedWithUsername:)]) 
        [_delegate OAuthTwitterController: self authenticatedWithUsername: [[self class] username]];
	//[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancel: (id) sender {
	if ([_delegate respondsToSelector: @selector(OAuthTwitterControllerCanceled:)]) [_delegate OAuthTwitterControllerCanceled: self];
	//[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//=============================================================================================================================
#pragma mark View Controller Stuff
- (void) loadView {
	[super loadView];
    
//	self.view = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 416)] autorelease];
//	_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kGGTwitterLoadingBackgroundImage]];
//	_backgroundView.frame =  CGRectMake(0, 0, 320, 416);//44
//	UIActivityIndicatorView* spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
//	[spinner startAnimating];
//	spinner.frame = CGRectMake((320 / 2) - (spinner.bounds.size.width / 2),
//							   (416 / 2) - (spinner.bounds.size.height / 2),
//							   spinner.bounds.size.width,
//							   spinner.bounds.size.height);
//	[_backgroundView addSubview:spinner];
//	
//	[self.view addSubview:_backgroundView];
//	
//	[self.view addSubview: _webView];
	
	//_navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, 320, 44)] autorelease];
	//[self.view addSubview: _navBar];
	
	//UINavigationItem				*navItem = [[[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Twitter Info", @"Twitter Info")] autorelease];
	//navItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancel:)] autorelease];
	
	//[_navBar pushNavigationItem: navItem animated: NO];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancel:)] autorelease];
    self.navigationItem.title = NSLocalizedString(@"Twitter Info", @"Twitter Info");
}


//=============================================================================================================================
//#pragma mark Webview Delegate stuff
//- (void) webViewDidFinishLoad: (UIWebView *) webView {
//	NSError *error;
//	NSString *path = [[NSBundle mainBundle] pathForResource: @"jQueryInject" ofType: @"txt"];
//    NSString *dataSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
//    
//    if (dataSource == nil) {
//        YFLog(@"An error occured while processing the jQueryInject file");
//    }
//	
//	[_webView stringByEvaluatingJavaScriptFromString:dataSource]; //This line injects the jQuery to make it look better
//	//check for auth_pin element
//	NSString *authPin = [[_webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('oauth_pin').innerHTML"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	if (authPin.length == 0)
//        authPin = [[_webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('oauth_pin').getElementsByTagName('a')[0].innerHTML"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    //if the auth pin not found than check for the auth-pin elenent
//    if (authPin == nil || authPin.length == 0) {
//        authPin = [[_webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('oauth-pin').innerHTML"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if (authPin.length == 0)
//            authPin = [[_webView stringByEvaluatingJavaScriptFromString: @"document.getElementById('oauth-pin').getElementsByTagName('a')[0].innerHTML"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    }
//    
//	[_activityIndicator stopAnimating];
//	if (authPin.length) {
//		[self gotPin: authPin];
//	} 
//	if ([_webView isLoading] || authPin.length) {
//		[_webView setHidden:YES];
//	} else {
//		[_webView setHidden:NO];
//	}
//}
//
//- (void) webViewDidStartLoad: (UIWebView *) webView {
//	[_activityIndicator startAnimating];
//}


//- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request navigationType: (UIWebViewNavigationType) navigationType {
//	NSData				*data = [request HTTPBody];
//	char				*raw = data ? (char *) [data bytes] : "";
//	
//	if (raw && strstr(raw, "cancel=Deny")) {
//		[self denied];
//		return NO;
//	}
//
//	[_webView setHidden:YES];
//	
//	if ([request HTTPShouldHandleCookies])
//	{
//		NSMutableURLRequest *noCookiesRequest = [[NSMutableURLRequest alloc] initWithURL:[request URL]];
//		[noCookiesRequest setHTTPBody:[request HTTPBody]];
//		[noCookiesRequest setHTTPMethod:[request HTTPMethod]];
//		[noCookiesRequest setAllHTTPHeaderFields:[request allHTTPHeaderFields]];
//		[noCookiesRequest setHTTPShouldHandleCookies:NO];
//		[noCookiesRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//		[_webView loadRequest:noCookiesRequest];
//		[noCookiesRequest release];
//		return NO;
//	}	
//	
//	return YES;
//}

@end
