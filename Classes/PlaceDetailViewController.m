//
//  PlaceDetailViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "PlaceDetailTitleTableCell.h"
#import "PlaceDetailGiftShoutTableCell.h"
#import "PlaceDetailMayorMapTableCell.h"

@implementation PlaceDetailViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // TODO: figure out why the switch doesn't work. very odd.
        if (indexPath.section == 0) {
            UIViewController *vc = [[UIViewController alloc]initWithNibName:@"PlaceTitleTableCellView" bundle:nil];
            cell = (PlaceDetailTitleTableCell*) vc.view;
            [vc release];
        } else if (indexPath.section == 1) {
            UIViewController *vc = [[UIViewController alloc]initWithNibName:@"PlaceGiftShoutTableCellView" bundle:nil];
            cell = (PlaceDetailGiftShoutTableCell*) vc.view;
            [vc release];
        } else if (indexPath.section == 2) {
            UIViewController *vc = [[UIViewController alloc]initWithNibName:@"PlaceMayorMapTableCellView" bundle:nil];
            cell = (PlaceDetailMayorMapTableCell*) vc.view;
            [vc release];
            
            // Google Static Maps API:  ABQIAAAAnrUlX7POdnZwsqXNLLWGTRTMzuZfXwYpjSHR_PURG9DdFdJWFxQJAauafQ6EM5PC-xeYd-P-GoM-pQ
            NSString *urlAddress = @"http://m.google.com/maps";
            NSURL *url = [NSURL URLWithString:urlAddress];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//            [((PlaceDetailMayorMapTableCell*)cell).mapView loadHTMLString:@"/maps" baseURL:[NSURL URLWithString:@"http://m.google.com"]];
            [((PlaceDetailMayorMapTableCell*)cell).mapView loadRequest:requestObj];
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
    }
    
    // Set up the cell...
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 62;
        case 2:
            return 62;
        default:
            return 44;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return NULL;
    } else {
        // create the parent view that will hold header Label
        UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor blackColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.highlightedTextColor = [UIColor grayColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:12];
        headerLabel.frame = CGRectMake(00.0, 0.0, 320.0, 24.0);
        
        // If you want to align the header text as centered
        // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
        switch (section) {
            case 0:
                break;
            case 1:
                break;
            case 2:
                // TODO: fix this
                headerLabel.text = @"  Mayor                        Map";
                break;
            case 3:
                headerLabel.text = @"  10 People Here";
                break;
            case 4:
                headerLabel.text = @"  Tips";
                break;
            default:
                headerLabel.text = @"You shouldn't see this";
                break;
        }
        //headerLabel.text = <Put here whatever you want to display> // i.e. array element
        [customView addSubview:headerLabel];
        [headerLabel release];
        return customView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

