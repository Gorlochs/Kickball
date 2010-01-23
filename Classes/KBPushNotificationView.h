//
//  KBPushNotificationView.h
//  Kickball
//
//  Created by Shawn Bernard on 1/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBPushNotificationView : UIViewController {
    IBOutlet UILabel *messageLabel;
    IBOutlet UILabel *addressLabel;
    IBOutlet UIButton *button;
}

@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UILabel *addressLabel;
@property (nonatomic, retain) UIButton *button;

@end
