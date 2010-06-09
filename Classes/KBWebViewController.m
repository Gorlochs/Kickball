//
//  KBWebViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBWebViewController.h"


@implementation KBWebViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrlString:(NSString*)url {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        urlString = url;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTwitterUrlString:(NSString*)url {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        twitterUrlString = url;
    }
    return self;
}

- (void)viewDidLoad {
    
    self.hideFooter = YES;
    [super viewDidLoad];
	[webView setDelegate:self];
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	if (twitterUrlString) {
        // this is for the mobile geo twitter page. it really needs to be oauth'd
		//MGTwitterHTTPURLConnection *conn = [[MGTwitterHTTPURLConnection alloc] initWithRequest:requestObj delegate:self requestType:nil responseType:nil];
	} else {
		
		//Load the request in the UIWebView.
		[webView loadRequest:requestObj];
	}
	spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
	[spinner retain];
	[spinner setHidesWhenStopped:YES];
	[spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[self.view addSubview:spinner];
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[spinner stopAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[spinner startAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
	[spinner release];
    [webView release];
    [urlString release];
    [super dealloc];
}


@end
