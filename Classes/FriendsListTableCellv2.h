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
    UILabel *numberOfTimeUnits;
	
    UIImageView *iconBgImage;
    UIImageView *crownImage;
	BOOL twoLine;
	BOOL hasShoutAndCheckin;
}

@property (nonatomic, retain) TTImageView *userIcon;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *venueName;
@property (nonatomic, retain) UILabel *venueAddress;
@property (nonatomic, retain) UILabel *numberOfTimeUnits;
@property (nonatomic, retain) UIImageView *crownImage;
@property (nonatomic) BOOL hasShoutAndCheckin;

- (void)makeTwoLine;
- (void)makeOneLine;

@end
