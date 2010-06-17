//
//  KBFacebookEventsCell.h
//  Kickball
//
//  Created by scott bates on 6/17/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBFacebookEventsCell : UITableViewCell {
	UILabel *eventHost;
	UILabel *eventName;
	UILabel *eventTime;
	UIImageView *topLineImage;
    UIImageView *bottomLineImage;
}

-(void)populate:(NSDictionary*)event;

@end
