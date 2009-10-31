//
//  PlaceDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlaceDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet UIWebView *mapView;
}

@property (nonatomic, retain) UITableViewCell *mayorMapCell;

- (IBAction) callVenue;

@end
