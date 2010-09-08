//
//  KBTwitterUserTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 4/28/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "CoreTableCellWithProfilePic.h"


@interface KBTwitterUserTableCell : CoreTableCellWithProfilePic {
    UILabel *userName;
	UIImageView *caret;
	
}

@property (nonatomic, retain) UILabel *userName;

@end
