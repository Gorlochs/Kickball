//
//  FriendsListTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FriendsListTableCell.h"


@implementation FriendsListTableCell
@synthesize checkinDisplayLabel, profileIcon;

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


- (void)dealloc {
    [super dealloc];
}


@end
