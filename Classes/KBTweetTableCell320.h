//
//  KBTweetTableCell320.h
//  Kickball
//
//  Created by scott bates on 6/8/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "Utilities.h"

@interface KBTweetTableCell320 : UITableViewCell {
	TTImageView *userIcon;
    
    UILabel *userName;
    TTStyledTextLabel *tweetText;
    UILabel *dateLabel;
    
    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
    UIImageView *iconBgImage;
}

@property (nonatomic, retain) TTImageView *userIcon;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) TTStyledTextLabel *tweetText;

- (void) setDateLabelWithDate:(NSDate*)theDate;
- (void) setDateLabelWithText:(NSString*)theDate;


@end
