//
//  KBTweetTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 4/18/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "IFTweetLabel.h"


@interface KBTweetTableCell : UITableViewCell {
    TTImageView *userIcon;
    
    UILabel *userName;
    //TTStyledTextLabel *tweetText;
    IFTweetLabel *tweetText;
    UILabel *dateLabel;
    
    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
    UIImageView *iconBgImage;
}

@property (nonatomic, retain) TTImageView *userIcon;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) IFTweetLabel *tweetText;

- (void) setDateLabelWithDate:(NSDate*)theDate;

@end