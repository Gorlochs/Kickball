//
//  KBTwitterCell.h
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTweetLabel.h"

@interface KBTwitterCell : UITableViewCell {
    IFTweetLabel *tweetLabel;
}

@property (nonatomic, retain) IFTweetLabel *tweetLabel;

@end
