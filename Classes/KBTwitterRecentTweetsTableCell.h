//
//  KBTwitterRecentTweetsTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 5/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTweetLabel.h"
#import "CoreTableCell.h"


@interface KBTwitterRecentTweetsTableCell : CoreTableCell {
    IFTweetLabel *tweetText;
    UILabel *dateLabel;
}

@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) IFTweetLabel *tweetText;

- (void) setDateLabelWithDate:(NSDate*)theDate;

@end