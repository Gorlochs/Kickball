//
//  PlacePeopleHereTableCell.h
//  Kickball
//
//  Created by scott bates on 9/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "CoreTableCellWithProfilePic.h"


@interface PlacePeopleHereTableCell : CoreTableCellWithProfilePic {
	UILabel *textLabel;	
	UIImageView *caret;
}
@property (nonatomic, retain) UILabel *textLabel;

@end
