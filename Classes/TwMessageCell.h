//
//  TwMessageCell.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 12/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageView.h"
#import "TwImageGridView.h"
#import "TwitterMessageObject.h"

@interface TwMessageCell : UITableViewCell {
@private
    UILabel         *_screennameLabel;
    UILabel         *_dateLabel;
    UILabel         *_messageLabel;
    CustomImageView *_avatarImage;
    UIImageView     *_favoriteImage;
    TwImageGridView *_imageGrid;
}

- (void)setTwitterMessageObject:(TwitterMessageObject*)object;

@end
