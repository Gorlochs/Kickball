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
#import "IFTweetLabel.h"
#import "CoreTableCellWithProfilePic.h"


@interface KBTweetTableCell320 : CoreTableCellWithProfilePic {
    
    UILabel *userName;
    IFTweetLabel *tweetText;
    UILabel *dateLabel;
    
}

@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) IFTweetLabel *tweetText;

- (void) setDateLabelWithDate:(NSDate*)theDate;
- (void) setDateLabelWithText:(NSString*)theDate;
- (void) pushToProfile;

@end
