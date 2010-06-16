//
//  KBFacebookSearchViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBFacebookSearchViewController.h"


@implementation KBFacebookSearchViewController

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

- (void)viewDidLoad {
    self.hideHeader = YES;
    self.hideFooter = YES;
    self.hideRefresh = YES;
    [super viewDidLoad];
    
    FBLoginButton* button = [[[FBLoginButton alloc] init] autorelease];
    button.frame = CGRectMake(10, 60, 100, 40);
    [self.view addSubview:button];
}

-(void)pressOptionsLeft{
	[[self navigationController] popViewControllerAnimated:YES];
}
-(void)pressOptionsRight{
	
}

#pragma mark -
#pragma mark FBSessionDelegate

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
//    _label.text = @"";
//    _permissionButton.hidden = NO;
//    _feedButton.hidden       = NO;
//    _statusButton.hidden     = NO;
//    _photoButton.hidden      = NO;
    
//    NSString* fql = [NSString stringWithFormat:@"select uid, name from user where uid == %lld", session.uid];
//    
//    //NSString *fql = [NSString stringWithFormat:@"SELECT flid,name FROM friendlist WHERE owner = %lld", session.uid];
//    
//    NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
//    [[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
    
    
    //[[FBRequest requestWithDelegate:self] call:@"facebook.Friends.get" params:nil];
}

- (void)sessionDidNotLogin:(FBSession*)session {
//    _label.text = @"Canceled login";
}

- (void)sessionDidLogout:(FBSession*)session {
//    _label.text = @"Disconnected";
//    _permissionButton.hidden = YES;
//    _feedButton.hidden       = YES;
//    _statusButton.hidden     = YES;
//    _photoButton.hidden      = YES;
}

#pragma mark -
#pragma mark FBRequestDelegate

- (void)request:(FBRequest*)request didLoad:(id)result {
//    if ([request.method isEqualToString:@"facebook.fql.query"]) {
//        NSArray* users = result;
//        NSDictionary* user = [users objectAtIndex:0];
//        NSString* name = [user objectForKey:@"name"];
//        DLog(@"FB user name: %@", name);
////        _label.text = [NSString stringWithFormat:@"Logged in as %@", name];
//    } else if ([request.method isEqualToString:@"facebook.users.setStatus"]) {
//        NSString* success = result;
////        if ([success isEqualToString:@"1"]) {
////            _label.text = [NSString stringWithFormat:@"Status successfully set"]; 
////        } else {
////            _label.text = [NSString stringWithFormat:@"Problem setting status"]; 
////        }
//    } else if ([request.method isEqualToString:@"facebook.photos.upload"]) {
//        NSDictionary* photoInfo = result;
//        NSString* pid = [photoInfo objectForKey:@"pid"];
////        _label.text = [NSString stringWithFormat:@"Uploaded with pid %@", pid];
//    } else if ([request.method isEqualToString:@"facebook.Friends.get"]) {
//        NSString* ids = result;
//        DLog(@"facebook friends: %@", ids);
//    }
}

- (void)askPermissionPublishStream {
    FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
    dialog.delegate = self;
    dialog.permission = @"publish_stream";
    [dialog show];
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
//    _label.text = [NSString stringWithFormat:@"Error(%d) %@", error.code,
//                   error.localizedDescription];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

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
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

