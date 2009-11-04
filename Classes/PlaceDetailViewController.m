//
//  PlaceDetailViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "ProfileViewController.h"

@interface PlaceDetailViewController (Private)

- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename;

@end


@implementation PlaceDetailViewController

@synthesize mayorMapCell;
@synthesize venue;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.001;
    span.longitudeDelta = 0.001;
    
    CLLocationCoordinate2D location = mapView.userLocation.coordinate;
    
    location.latitude =  [venue.geolat doubleValue];
    location.longitude = [venue.geolong doubleValue];
    region.span = span;
    region.center = location;
    
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
    
    venueName.text = venue.name;
    venueAddress.text = venue.venueAddress;
    //mayorImage.image = venue.
    
    //NSArray * allCheckins = [FoursquareAPI 
}


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
    theTableView = nil;
    mayorMapCell = nil;
    mapView = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        // TODO: return the number of people if < X, otherwise return MAX_NUMBER_OF_PEOPLE_HERE
        return 4;
    } else {
        return 1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    // FIXME: something is f'd up.  Maybe a memory issue or something. 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // FIXME: I don't know what I was thinking. These shouldn't be cells, they should be part of the view, or separate subview
        // TODO: figure out why the switch doesn't work. very odd.
        if (indexPath.section == 0) {
//            NSString *urlAddress = @"http://www.literalshore.com/gorloch/kickball/google.html";
//            NSURL *url = [NSURL URLWithString:urlAddress];
//            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//            [mapView loadRequest:requestObj];
            return mayorMapCell;
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    
    // Set up the cell...
    
    if (indexPath.section == 1) {
        cell.textLabel.text = @"Shawn";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"temp-icon.png"];
    }
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 62;
    } else {
        return 44;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
            // TODO: fix this
            headerLabel.text = @"  Mayor                        Map";
            break;
        case 1:
            headerLabel.text = @"  10 People Here";
            break;
        case 2:
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ProfileViewController *profileDetailController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    [self.view addSubview:profileDetailController.view];
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
    [theTableView release];
    [mayorMapCell release];
    [mapView release];
    [super dealloc];
}

#pragma mark IBAction methods

// TODO: pull in correct phone number
- (void) callVenue {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:503-555-1212"]];
}

- (void) uploadImageToServer {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePickerController animated:YES];
}

#pragma mark Image Picker Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // hide picker
    [picker dismissModalViewControllerAnimated:YES];
    
    // upload image
    // TODO: this would also have to save the image to the DB and we'd have to confirm success to the user.
    //       we also need to send a notification to the gift recipient
    [self uploadImage:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 1.0) filename:@"foobar2.jpg"];
}

#pragma mark private methods

// TODO: set max file size
- (BOOL)uploadImage:(NSData *)imageData filename:(NSString *)filename{
    
    // TODO: create some semi-secure key to pass into the PHP page
    NSString *urlString = @"http://www.literalshore.com/gorloch/kickball/upload.php";
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n",filename]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSLog(@"request: %@", request);
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    return ([returnString isEqualToString:@"OK"]);
}

@end

