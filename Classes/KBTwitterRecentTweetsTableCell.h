//
//  KBTwitterRecentTweetsTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 5/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTweetLabel.h"


@interface KBTwitterRecentTweetsTableCell : UITableViewCell {
    IFTweetLabel *tweetText;
    UILabel *dateLabel;
    
    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
    
    UIButton *retweetButton;
}

@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) IFTweetLabel *tweetText;

- (void) setDateLabelWithDate:(NSDate*)theDate;

@end