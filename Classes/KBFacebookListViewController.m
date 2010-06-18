    //
//  KBFacebookListViewController.m
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookListViewController.h"
#import "KBFacebookNewsCell.h"
#import "KBFacebookLoginView.h"
#import "KBFacebookPostDetailViewController.h"
#import "FacebookProxy.h"
#import "GraphObject.h"
#import "KickballAPI.h"

@interface KBFacebookStyleSheet : TTDefaultStyleSheet
@end

@implementation KBFacebookStyleSheet

- (TTStyle*)fbBlueText {
	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:12.0] color:[UIColor colorWithRed:76/255.0 green:127/255.0 blue:220/255.0 alpha:1.0]
					  minimumFontSize:12 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
						 shadowOffset:CGSizeMake(0, -1) next:nil];
}
@end

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
	[TTStyleSheet setGlobalStyleSheet:[[[KBFacebookStyleSheet alloc] init] autorelease]];
	pageType = KBPageTypeFriends;
	pageNum = 1;
    pageViewType = KBPageViewTypeList;
    [super viewDidLoad];
	doingLogin = NO;
	newsFeed = nil;
	[FacebookProxy loadDefaults];
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
	if (newsFeed!=nil) {
		GraphObject *fbItem = [newsFeed objectAtIndex:indexPath.row];
		NSString *displayString = [NSString	 stringWithFormat:@"%@ %@",[(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"name"], [fbItem propertyWithKey:@"message"]];
		CGSize maximumLabelSize = CGSizeMake(250, 400);
		CGSize expectedLabelSize = [displayString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]
											 constrainedToSize:maximumLabelSize 
												 lineBreakMode:UILineBreakModeWordWrap];
		int calculatedHeight = expectedLabelSize.height + 38;
		//if (calculatedHeight>50) {
			return calculatedHeight;
		//}
	}
	return 60;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBFacebookNewsCell *cell = (KBFacebookNewsCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[KBFacebookNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	GraphObject *fbItem = [newsFeed objectAtIndex:indexPath.row];
	NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"name"], [fbItem propertyWithKey:@"message"]];
	cell.fbPictureUrl = [(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"id"];
	cell.tweetText.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
	[cell setNumberOfComments:[(NSArray*)[(NSDictionary*)[fbItem propertyWithKey:@"comments"] objectForKey:@"data"] count]];
	[cell setDateLabelWithText:[[KickballAPI kickballApi] convertDateToTimeUnitString:[[FacebookProxy fbDateFormatter] dateFromString:[fbItem propertyWithKey:@"created_time"]]]];
	[cell.tweetText sizeToFit];
	[cell.tweetText setNeedsDisplay];
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        KBFacebookPostDetailViewController *detailViewController = [[KBFacebookPostDetailViewController alloc] initWithNibName:@"KBFacebookPostDetailViewController" bundle:nil];
        //detailViewController.tweet = [tweets objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
    } else {
        //[self executeQuery:++pageNum];
    }
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
	[TTStyleSheet setGlobalStyleSheet:nil];
	[newsFeed release];
	[fbLoginView release];
    [super dealloc];
}


@end