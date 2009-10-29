//
//  PlaceDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlaceDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
}

@end
