//
//  KBFacebookEventsCell.h
//  Kickball
//
//  Created by scott bates on 6/17/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTableCell.h"

@interface KBFacebookEventsCell : CoreTableCell {
	UILabel *eventHost;
	UILabel *eventName;
	UILabel *eventTime;

}

-(void)populate:(NSDictionary*)event;

@end
