    //
//  KBFacebookEventsListViewController.m
//  Kickball
//
//  Created by scott bates on 6/15/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookEventsListViewController.h"
#import "KBFacebookNewsCell.h"
#import "GraphAPI.h"
#import	"GraphObject.h"
#import "FacebookProxy.h"
#import "KickballAPI.h"
#import "KBFacebookPostDetailViewController.h"

@implementation KBFacebookEventsListViewController

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
NSInteger eventsDateSort(id e1, id e2, void *context) {
    /* A private comparator fcn to sort two mountains.  To do so,
     we do a localized compare of mountain names, using 
     NSString:localizedCompare. */
    NSDate *e1Date = nil;
	NSDate *e2Date = nil;
    if (e1 != nil && [e1 isKindOfClass:[GraphObject class]] &&
        e2 != nil && [e2 isKindOfClass:[GraphObject class]]) {
        e1Date = [[FacebookProxy fbDateFormatter] dateFromString:[e1 propertyWithKey:@"start_time"]];
        e2Date = [[FacebookProxy fbDateFormatter] dateFromString:[e2 propertyWithKey:@"start_time"]];
    }
    return [e1Date compare:e2Date];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	pageType = KBpageTypeEvents;
    pageViewType = KBPageViewTypeList;
    
    [super viewDidLoad];
    
    noResultsView.hidden = NO;
    
    //DLog(@"PlacesListViewController get venue - geolat: %f", [[KBLocationManager locationManager] latitude]);
    //DLog(@"PlacesListViewController get venue - geolong: %f", [[KBLocationManager locationManager] longitude]);
    [self addHeaderAndFooter:theTableView];
        
    isSearchEmpty = NO;
    [FlurryAPI logEvent:@"Facebook Events List"];
	if ([[FacebookProxy instance] isAuthorized]) {
		//[self startProgressBar:@"Retrieving your tweets..."];
		//[self showStatuses];
		//[self refreshMainFeed];
		[self startProgressBar:@"Retrieving events..."];
		[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];
		
	} else {
		[self showLoginView];
        //loginController = [[KBTwitterXAuthLoginController alloc] initWithNibName:@"TwitterLoginView_v2" bundle:nil];
		//loginController.rootController = self;
        //[self presentModalViewController:loginController animated:YES];
    }
}

-(void)refreshMainFeed{
	[eventsFeed release];
	eventsFeed = nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// = [[FacebookProxy instance] refreshEvents];
	//GraphObject *baseObj = [baseEventResult objectAtIndex:0];
	NSArray *baseEventResult = [[FacebookProxy instance] refreshEvents];
	NSArray *sortedEvents = [baseEventResult sortedArrayUsingFunction:eventsDateSort context:NULL];
	NSMutableArray *futureEvents = [[NSMutableArray alloc] init];
	/*
	for (GraphObject* fbEvent in sortedEvents) {
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDateComponents *components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
		NSDate *today = [cal dateFromComponents:components];
		components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:aDate];
		NSDate *otherDate = [cal dateFromComponents:components];
		
		if([today isEqualToDate:otherDate]) {
			//do stuff
		}
	}*/
	
	eventsFeed  = sortedEvents;
	
	[eventsFeed retain];
	[theTableView reloadData];
	if ([eventsFeed count]>0) {
		noResultsView.hidden = YES;
	}
	
	//sort array based on date 
	//make sub-array of only future dates
	//group arrays based on common dates into array of dictionaries
	// as part of the grouping process call out and get event specific info and store that as well.
	
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
	if (eventsFeed!=nil) {
		return [eventsFeed count];
	}
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (eventsFeed!=nil) {
		GraphObject *fbItem = [eventsFeed objectAtIndex:indexPath.row];
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
	GraphObject *fbItem = [eventsFeed objectAtIndex:indexPath.row];
	NSString *displayString = [fbItem propertyWithKey:@"name"];
	//cell.fbPictureUrl = [(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"id"];
	cell.tweetText.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
	//[cell setNumberOfComments:[(NSArray*)[(NSDictionary*)[fbItem propertyWithKey:@"comments"] objectForKey:@"data"] count]];
	[cell setDateLabelWithText:[[KickballAPI kickballApi] convertDateToTimeUnitString:[[FacebookProxy fbDateFormatter] dateFromString:[fbItem propertyWithKey:@"start_time"]]]];
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
    [super dealloc];
}


@end
