//
//  KBCreateTweetViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTwitterViewController.h"


@interface KBCreateTweetViewController : KBTwitterViewController <UITextViewDelegate, MGTwitterEngineDelegate> {
    IBOutlet UITextView *tweetTextView;
    IBOutlet UILabel *characterCountLabel;
    IBOutlet UIButton *sendTweet;
    IBOutlet UIButton *cancel;
    IBOutlet UIButton *geoTag;
    IBOutlet UIButton *attachPhoto;
    
    NSNumber *replyToStatusId;
    NSString *replyToScreenName;
}

@property (nonatomic, retain) NSNumber *replyToStatusId;
@property (nonatomic, retain) NSString *replyToScreenName;

- (IBAction) submitTweet;
- (IBAction) cancelCreate;

@end