//
//  FriendsListTableCellv2.h
//  Kickball
//
//  Created by Shawn Bernard on 3/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBInstacheckinTableCell.h"

@interface FriendsListTableCellv2 : KBInstacheckinTableCell {
    TTImageView *userIcon;
    
    UILabel *userName;
    UILabel *venueName;
    UILabel *venueAddress;
    
    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
    UIImageView *iconBgImage;
	BOOL twoLine;
}

@property (nonatomic, retain) TTImageView *userIcon;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *venueName;
@property (nonatomic, retain) UILabel *venueAddress;

- (void)makeTwoLine;
- (void)makeOneLine;

@end
