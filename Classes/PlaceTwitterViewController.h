//
//  PlaceTwitterViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTwitterManagerDelegate.h"
#import "KBFoursquareViewController.h"


@interface PlaceTwitterViewController : KBFoursquareViewController <UITableViewDelegate, UITableViewDataSource, KBTwitterManagerDelegate> {
    NSString *twitterName;
    NSArray *twitterStatuses;
    NSString *venueName;
    IBOutlet UILabel *venueLabel;
    NSMutableDictionary *orderedTweets;
    NSArray *sortedKeys;
}

@property (nonatomic, retain) NSString *twitterName;
@property (nonatomic, retain) NSString *venueName;

@end
