//
//  FriendsListTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 10/26/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendsListTableCell : UITableViewCell {
	IBOutlet UIImageView * profileIcon;
	IBOutlet UILabel * checkinDisplayLabel;
	IBOutlet UILabel * addressLabel;
    IBOutlet UILabel * timeUnits;
    IBOutlet UILabel * numberOfTimeUnits;
    IBOutlet UIImageView *mayorImage;
}

@property (nonatomic, retain) UIImageView * profileIcon;
@property (nonatomic, retain) UILabel * checkinDisplayLabel;
@property (nonatomic, retain) UILabel * addressLabel;
@property (nonatomic, retain) UILabel * timeUnits;
@property (nonatomic, retain) UILabel * numberOfTimeUnits;

- (void) showHideMayorImage:(BOOL)isMayor;
- (void) displayMayorImage;
- (void) hideMayorImage;

@end
