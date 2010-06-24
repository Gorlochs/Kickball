//
//  VersionInfoViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "VersionInfoViewController.h"


@implementation VersionInfoViewController

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    self.hideHeader = YES;
    
    [super viewDidLoad];
	
	//load web URL
	//http://s3.amazonaws.com/kickball/version/version.1.1.html
	//NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://s3.amazonaws.com/kickball/version/version.1.1.html"]];
	//NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gorlochs.com/kickball/app/version/version.1.1.html"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.22greystreet.com/kickball/version.1.1.html"]];
	[webView loadRequest:request];


}

-(void)pressOptionsLeft{
	[[self navigationController] popViewControllerAnimated:YES];

}
-(void)pressOptionsRight{
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
