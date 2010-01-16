//
//  FriendsListTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 10/26/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FriendsListTableCell.h"


@implementation FriendsListTableCell
@synthesize checkinDisplayLabel, addressLabel, profileIcon, numberOfTimeUnits, timeUnits;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) showHideMayorImage:(BOOL)isMayor {
    if (isMayor) {
        [self displayMayorImage];
    } else {
        [self hideMayorImage];
    }
}

- (void) displayMayorImage {
    mayorImage.image = [UIImage imageNamed:@"crown.png"];
    checkinDisplayLabel.frame = CGRectMake(65.0, checkinDisplayLabel.frame.origin.y, checkinDisplayLabel.frame.size.width, checkinDisplayLabel.frame.size.height);
}

- (void) hideMayorImage {
    mayorImage.image = nil;
    checkinDisplayLabel.frame = CGRectMake(44.0, checkinDisplayLabel.frame.origin.y, checkinDisplayLabel.frame.size.width, checkinDisplayLabel.frame.size.height);
}

- (void)dealloc {
    [profileIcon release];
	[checkinDisplayLabel release];
	[addressLabel release];
    [timeUnits release];
    [numberOfTimeUnits release];
    [mayorImage release];
    [super dealloc];
}


@end
