//
//  PlaceTwitterViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngineDelegate.h"

@interface PlaceTwitterViewController : UITableViewController <MGTwitterEngineDelegate> {
    NSString *twitterName;
    NSArray *twitterStatuses;
}

@property (nonatomic, retain) NSString *twitterName;

@end
