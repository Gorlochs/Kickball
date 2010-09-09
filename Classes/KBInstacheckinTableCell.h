//
//  KBInstacheckinTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 4/1/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTableCell.h"


@interface KBInstacheckinTableCell : CoreTableCell {
    BOOL _cancelTouches;
    NSString *venueId;
	CGPoint touchLocation;
	UIImageView *spinnerView;
}

@property (nonatomic) BOOL _cancelTouches;
@property (nonatomic, retain) NSString *venueId;
-(void) startSpinner;
-(void) stopSpinner;

@end
