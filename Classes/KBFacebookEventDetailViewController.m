//
//  KBFacebookEventDetailViewController.m
//  Kickball
//
//  Created by scott bates on 6/17/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookEventDetailViewController.h"
#import "TableSectionHeaderView.h"
#import "KBFacebookEventsCell.h"
@implementation KBFacebookEventDetailViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.hideFooter = YES;
    pageType = KBPageTypeOther;
    [super viewDidLoad];
	NSString *content = nil;
	content = [event objectForKey:@"host"];
	eventHost.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
	content = [event objectForKey:@"name"];
	eventName.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
	content = [event objectForKey:@"location"];
	eventLocation.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
	eventTime.text = @"6:30p";//[event objectForKey:];
	eventMonth.text = @"SEP"; //[event objectForKey:@"24"];
	eventDay.text = @"24"; //[event objectForKey:];
	content = [event objectForKey:@"description"];
	detailText.font = [UIFont systemFontOfSize:14.0];
	detailText.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
	NSString *rsvp = [event objectForKey:@"rsvp_status"];
	[attendingButt setSelected:NO];
	[notAttendingButt setSelected:NO];
	[attendingButt setEnabled:YES];
	[notAttendingButt setEnabled:YES];
	if ([rsvp isEqualToString:@"attending"]) {
		[attendingButt setSelected:YES];
		//[attendingButt setEnabled:NO];
	}else if([rsvp isEqualToString:@"declined"]) {
		[notAttendingButt setSelected:YES];
		//[notAttendingButt setEnabled:NO];
	}
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)populate:(NSDictionary*)ev{
	event = [ev copy];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 2;
		case 1:
			//return the number of comments
			return 0;
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section) {
		case 0:
			if (indexPath.row==0) {
				//calculate hight for detail cell
				return 100;
			}else {
				return 46;
			}
		case 1:
			//calculate height of comment cell
			return 60;
		default:
			return 44;
	}
	
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
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	TableSectionHeaderView *sectionHeaderView;
	switch (section) {
		case 0:
			return nil;
		case 1:
			//if (eventsFeed!=nil) {
			//	NSDictionary *sectionDict = [eventsFeed objectAtIndex:section];
			//	if (sectionDict!=nil) {
			//		NSString *headerString = [sectionDict objectForKey:@"headerString"];
			//		if (headerString!=nil) {
						sectionHeaderView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
						sectionHeaderView.leftHeaderLabel.text = @"Comments";
						sectionHeaderView.rightHeaderLabel.text = @"";
						return sectionHeaderView;
			//		}else {
			//			return nil;
			//		}
			//		
			//	}else {
			//		return nil;
			//	}
			//}
		default:
			return nil;
	}
		
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	KBFacebookEventsCell *cell;
	switch (indexPath.section) {
		case 0:
			if (indexPath.row==0) {
				//calculate hight for detail cell
				return detailCell;
			}else {
				return actionCell;
			}
		case 1:
			
			 cell = (KBFacebookEventsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[KBFacebookEventsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			//NSDictionary *fbItem = [(NSArray*)[(NSDictionary*)[eventsFeed objectAtIndex:indexPath.section] objectForKey:@"events"] objectAtIndex:indexPath.row];
			//[cell populate:fbItem];
			return cell;
		default:
			return nil;
	}
	
	
    
}

-(IBAction)pressAttending{
	
}
-(IBAction)pressNotAttending{
	
}
-(IBAction)touchComment{
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:NO];
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
	[event release];
    [super dealloc];
}


@end
