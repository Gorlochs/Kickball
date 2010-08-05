//
//  KBWebViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBWebViewController.h"


@implementation KBWebViewController

@synthesize theWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrlString:(NSString*)url {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        urlString = [url retain];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTwitterUrlString:(NSString*)url {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        twitterUrlString = [url retain];
    }
    return self;
}

- (void)viewDidLoad {
	self.hideFooter = YES;
	self.hideHeader = YES;
    [super viewDidLoad];
	[theWebView setDelegate:self];
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	[self retain];
    if ([theWebView isLoading])
        [theWebView stopLoading];
    [theWebView loadRequest:requestObj];
    [self release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#pragma unused(interfaceOrientation)
  return YES;
}

- (void) forward {
    [theWebView goForward];
}

- (void) back {
    [theWebView goBack];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[self stopProgressBar];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    backButton.enabled = [webView canGoBack];
    forwardButton.enabled = [webView canGoForward];
    [self release];
    CGRect frame = webView.frame;
    frame.size.height *= 4; //fix for odd web view bug that can't detect the right height for a webpage. exists is safari as well
    webView.frame = frame;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self startProgressBar:@"Loading web page..." withTimer:NO andLongerTime:NO];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[self retain];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self release];
}

- (void)viewWillDisappear {
    if ([theWebView isLoading])
        [theWebView stopLoading];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) dismissView {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)dealloc {
    [theWebView setDelegate:nil];
    [theWebView release];
    theWebView = nil;
	
    [urlString release];
	[twitterUrlString release];
    [super dealloc];
}


@end
