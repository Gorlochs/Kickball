//
//  PlacesListTableViewCellv2.h
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBInstacheckinTableCell.h"


@interface PlacesListTableViewCellv2 : KBInstacheckinTableCell {
    TTImageView *categoryIcon;

    UILabel *venueName;
    UILabel *venueAddress;
    
    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
}

@property (nonatomic, retain) TTImageView *categoryIcon;
@property (nonatomic, retain) UILabel *venueName;
@property (nonatomic, retain) UILabel *venueAddress;

@end
