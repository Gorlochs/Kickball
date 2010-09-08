//
//  CoreTableCellWithProfilePic.h
//  Kickball
//
//  Created by scott bates on 9/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "CoreTableCell.h"

@interface CoreTableCellWithProfilePic : CoreTableCell {
	TTImageView *userIcon;
	UIImageView *iconBgImage;
	UIButton *iconButt;
}

@property (nonatomic, retain) TTImageView *userIcon;

- (void) pushToProfile;
@end
