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
    IBOutlet UITableViewCell *titleCell;
    IBOutlet UITableViewCell *mayorMapCell;
    IBOutlet UITableViewCell *giftShoutCell;
    IBOutlet UIWebView *mapView;
}

@property (nonatomic, retain) UITableViewCell *titleCell;
@property (nonatomic, retain) UITableViewCell *mayorMapCell;
@property (nonatomic, retain) UITableViewCell *giftShoutCell;

- (IBAction) callVenue;

@end
