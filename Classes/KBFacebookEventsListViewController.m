    //
//  KBFacebookEventsListViewController.m
//  Kickball
//
//  Created by scott bates on 6/15/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookEventsListViewController.h"
#import "KBFacebookEventsCell.h"
#import "GraphAPI.h"
#import	"GraphObject.h"
#import "FacebookProxy.h"
#import "KickballAPI.h"
#import "KBFacebookPostDetailViewController.h"
#import "KBFacebookEventDetailViewController.h"
#import "TableSectionHeaderView.h"

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
    if (e1 != nil && [e1 isKindOfClass:[NSDictionary class]] &&
        e2 != nil && [e2 isKindOfClass:[NSDictionary class]]) {
        //e1Date = [[FacebookProxy fbDateFormatter] dateFromString:[e1 propertyWithKey:@"start_time"]];
        //e2Date = [[FacebookProxy fbDateFormatter] dateFromString:[e2 propertyWithKey:@"start_time"]];
		NSTimeInterval e1Epoch = [(NSString*)[(NSDictionary*)e1 objectForKey:@"start_time"] intValue];
		NSTimeInterval e2Epoch = [(NSString*)[(NSDictionary*)e2 objectForKey:@"start_time"] intValue];
		e1Date = [NSDate dateWithTimeIntervalSince1970:e1Epoch];
		e2Date = [NSDate dateWithTimeIntervalSince1970:e2Epoch];
    }
    return [e1Date compare:e2Date];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	pageType = KBpageTypeEvents;
    pageViewType = KBPageViewTypeList;
    eventsFeed = nil;
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
	NSMutableArray *futureSections = [[NSMutableArray alloc] init];
	NSMutableArray * todayEvents = [[NSMutableArray alloc] init];
	NSMutableArray * tomorrowEvents = [[NSMutableArray alloc] init];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
	NSDate *today = [cal dateFromComponents:components];
	
	
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *tomorrow = [cal dateByAddingComponents:offsetComponents toDate:today options:0];
	[offsetComponents release];
	NSDate *lastFutureDate = [today copy];
	for (NSDictionary* fbEvent in sortedEvents) {
		
		NSDate *fbEventDate = [NSDate dateWithTimeIntervalSince1970:[(NSString*)[fbEvent objectForKey:@"start_time"] intValue]];
		[fbEventDate addTimeInterval:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
		components = [cal components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:fbEventDate];
		NSDate *eventDate = [cal dateFromComponents:components];
		
		if([today isEqualToDate:eventDate]) {
			[todayEvents addObject:fbEvent];
		}else if([tomorrow isEqualToDate:eventDate]) {
			[tomorrowEvents addObject:fbEvent];
		}else {
			NSDate *later = [eventDate laterDate:today];
			if ([later isEqualToDate:eventDate]) {
				//this is a future event
				//is this event on the same day as another future event?
				if([lastFutureDate isEqualToDate:eventDate]){
					//yes these events are on the same day, so add this event to the current dictionary
					[futureEvents addObject:fbEvent];
				}else {
					//it's a new day so:
					//if there are events in current dictionary, push it as a new section
					//release and re-alloc current dictionary
					//add self to current dictionary
					//set last futureDate to this on
					if ([futureEvents count]>0) {
						//create date string
						NSString *sectionHeader = [[FacebookProxy fbEventSectionFormatter] stringFromDate:lastFutureDate];
						NSDictionary *newSection = [NSDictionary dictionaryWithObjectsAndKeys:sectionHeader,@"headerString",futureEvents,@"events",nil];
						[futureSections addObject:newSection];
						[futureEvents release];
						futureEvents = nil;
						futureEvents = [[NSMutableArray alloc] init];
					}
					[futureEvents addObject:fbEvent];
					[lastFutureDate release];
					lastFutureDate = [eventDate copy];
				}
			}
		}

	}
	if ([futureEvents count]>0) {
		//create date string
		NSString *sectionHeader = [[FacebookProxy fbEventSectionFormatter] stringFromDate:lastFutureDate];
		NSDictionary *newSection = [NSDictionary dictionaryWithObjectsAndKeys:sectionHeader,@"headerString",futureEvents,@"events",nil];
		[futureSections addObject:newSection];
	}
	[futureEvents release];
	futureEvents = nil;
	[lastFutureDate release];
	lastFutureDate = nil;
	
	//now that I have a simple array I need to make a sectioned array
	////create days for today and for tomorrow
	eventsFeed = [[NSMutableArray alloc] init];
	if ([todayEvents count]>0) {
		NSDictionary *newSection = [NSDictionary dictionaryWithObjectsAndKeys:@"Today",@"headerString",todayEvents,@"events",nil];
		[eventsFeed addObject:newSection];
	}
	if ([tomorrowEvents count]>0) {
		NSDictionary *newSection = [NSDictionary dictionaryWithObjectsAndKeys:@"Tomorrow",@"headerString",tomorrowEvents,@"events",nil];
		[eventsFeed addObject:newSection];
	}
	
	[eventsFeed addObjectsFromArray:futureSections];
	
	//[eventsFeed retain];
	[todayEvents release];
	[tomorrowEvents release];
	[futureSections release];
	
	[theTableView reloadData];
	if ([eventsFeed count]>0) {
		noResultsView.hidden = YES;
	}
	
	//sort array based on date 
	//make sub-array of only future dates
	//group arrays based on common dates into array of dictionaries
	// as part of the grouping process call out and get event specific info and store that as well.
	
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
	[self dataSourceDidFinishLoadingNewData];
	[pool release];

	
}


- (void) refreshTable {
	//[self startProgressBar:@"Retrieving news feed..."];
	[self refreshMainFeed];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (eventsFeed!=nil) {
		if ([eventsFeed count]>0) {
			return [eventsFeed count];
		}else {
			return 1;
		}

	}
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (eventsFeed!=nil) {
		NSDictionary *sectionDict = [eventsFeed objectAtIndex:section];
		if (sectionDict!=nil) {
			NSArray *rows = [sectionDict objectForKey:@"events"];
			if (rows!=nil) {
				return [rows count];
			}else {
				return 0;
			}

		}else {
			return 0;
		}
	}
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	/*
	if (eventsFeed!=nil) {
		NSDictionary *fbItem = [eventsFeed objectAtIndex:indexPath.row];
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
	 */
	return 60;
	
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (eventsFeed!=nil) {
		NSDictionary *sectionDict = [eventsFeed objectAtIndex:section];
		if (sectionDict!=nil) {
			NSString *headerString = [sectionDict objectForKey:@"headerString"];
			if (headerString!=nil) {
				TableSectionHeaderView *sectionHeaderView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
				sectionHeaderView.leftHeaderLabel.text = headerString;
                sectionHeaderView.rightHeaderLabel.text = @"";
				return sectionHeaderView;
			}else {
				return nil;
			}
			
		}else {
			return nil;
		}
	}
    return nil;
	
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBFacebookEventsCell *cell = (KBFacebookEventsCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[KBFacebookEventsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	NSDictionary *fbItem = [(NSArray*)[(NSDictionary*)[eventsFeed objectAtIndex:indexPath.section] objectForKey:@"events"] objectAtIndex:indexPath.row];
	[cell populate:fbItem];
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
    KBFacebookEventDetailViewController *detailViewController = [[KBFacebookEventDetailViewController alloc] initWithNibName:@"KBFacebookEventDetailViewController" bundle:nil];
	NSDictionary *fbItem = [(NSArray*)[(NSDictionary*)[eventsFeed objectAtIndex:indexPath.section] objectForKey:@"events"] objectAtIndex:indexPath.row];
	[detailViewController populate:fbItem];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
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
	[eventsFeed release];
    [super dealloc];
}


@end
