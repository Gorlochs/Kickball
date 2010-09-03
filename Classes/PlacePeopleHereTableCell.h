//
//  PlacePeopleHereTableCell.h
//  Kickball
//
//  Created by scott bates on 9/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"


@interface PlacePeopleHereTableCell : UITableViewCell {
	TTImageView *imageIcon;
	UIImageView *topLineImage;
    UIImageView *bottomLineImage;
    UIImageView *iconBgImage;
	UILabel *textLabel;	
}
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) TTImageView *imageIcon;

@end
