//
//  HistoryViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 2/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface HistoryViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    NSArray *checkins;
    NSDateFormatter *dateFormatterS2D;
    NSDateFormatter *dateFormatterD2S;
    
    NSMutableArray *checkinDaysOfWeek;
}

@end
