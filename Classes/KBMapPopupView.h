//
//  KBMapPopupView.h
//  Kickball
//
//  Created by Shawn Bernard on 5/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTweetLabel.h"
#import "Three20/Three20.h"

@interface KBMapPopupView : UIView {
    IBOutlet UILabel *screenname;
    UILabel *tweetText;
	TTImageView *userIcon;
}

@property (nonatomic, retain) UILabel *screenname;
@property (nonatomic, retain) UILabel *tweetText;
@property (nonatomic, retain) TTImageView *userIcon;

@end
