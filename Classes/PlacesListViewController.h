//
//  PlacesListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlacesListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *searchCell;
}

@property (nonatomic, retain) UITableViewCell *searchCell;

@end
