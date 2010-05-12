//
//  KBMapPopupView.h
//  Kickball
//
//  Created by Shawn Bernard on 5/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTweetLabel.h"


@interface KBMapPopupView : UIView {
    IBOutlet UILabel *screenname;
    IFTweetLabel *tweetText;
}

@property (nonatomic, retain) UILabel *screenname;
@property (nonatomic, retain) IFTweetLabel *tweetText;

@end
