    //
//  KBFacebookListViewController.m
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookListViewController.h"
#import "KBTweetTableCell320.h"
#import "KBFacebookLoginView.h"
#import "FacebookProxy.h"
#import "GraphObject.h"

@implementation KBFacebookListViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	pageType = KBPageTypeFriends;
	pageNum = 1;
    pageViewType = KBPageViewTypeList;
	fbLoginView = nil;
    [super viewDidLoad];
	doingLogin = NO;
	newsFeed = nil;
	[FacebookProxy loadDefaults];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killLoginView) name:@"completedFacebookLogin" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginView) name:@"completedFacebookLogout" object:nil];
	if ([[FacebookProxy instance] isAuthorized]) {
		//[self startProgressBar:@"Retrieving your tweets..."];
		//[self showStatuses];
		//[self refreshMainFeed];
		[self startProgressBar:@"Retrieving news feed..."];
		[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];

	} else {
		[self showLoginView];
        //loginController = [[KBTwitterXAuthLoginController alloc] initWithNibName:@"TwitterLoginView_v2" bundle:nil];
		//loginController.rootController = self;
        //[self presentModalViewController:loginController animated:YES];
    }
}
-(void)killLoginView{
	//hide loginView and load user info
	if (fbLoginView!=nil) {
		[fbLoginView removeFromSuperview];
		[fbLoginView release];
		fbLoginView = nil;
		//[self refreshMainFeed];
		[self startProgressBar:@"Retrieving news feed..."];
		[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];

	}
	
}
-(void)showLoginView{
	fbLoginView = [[KBFacebookLoginView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
	[self.view addSubview:fbLoginView];
}

-(void)refreshMainFeed{
	[newsFeed release];
	newsFeed = nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	newsFeed = [[FacebookProxy instance] refreshHome];
	[newsFeed retain];
	[theTableView reloadData];
	[pool release];
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
	[self dataSourceDidFinishLoadingNewData];

}

- (void) refreshTable {
	//[self startProgressBar:@"Retrieving news feed..."];
	[self refreshMainFeed];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (newsFeed!=nil) {
		return [newsFeed count];
	}
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTweetTableCell320 *cell = (KBTweetTableCell320*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[KBTweetTableCell320 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	GraphObject *fbItem = [newsFeed objectAtIndex:indexPath.row];
	//cell.userIcon.urlPath = tweet.profileImageUrl;
	cell.userName.text = [(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"name"]; //tweet.screenName;
	//cell.tweetText.numberOfLines = 0;
	//cell.tweetText.text = tweet.tweetText;
	cell.tweetText.text = [TTStyledText textWithURLs:[fbItem propertyWithKey:@"message"] lineBreaks:NO]; //tweet.tweetText;
	//[cell setDateLabelWithDate:tweet.createDate];
	//[cell setDateLabelWithText:[[KickballAPI kickballApi] convertDateToTimeUnitString:tweet.createDate]];
	[cell.tweetText sizeToFit];
	//[cell.tweetText setNeedsLayout];
	[cell.tweetText setNeedsDisplay];
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[newsFeed release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[fbLoginView release];
    [super dealloc];
}


@end
