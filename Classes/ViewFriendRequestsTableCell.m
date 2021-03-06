//
//  ViewFriendRequestsTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 1/14/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "ViewFriendRequestsTableCell.h"


@implementation ViewFriendRequestsTableCell

@synthesize acceptFriendButton, denyFriendButton, friendName, rowCarat;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

-(void)pressOptionsLeft{
	[[self navigationController] popViewControllerAnimated:YES];
}
-(void)pressOptionsRight{
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [acceptFriendButton release];
    [denyFriendButton release];
    [friendName release];
    [rowCarat release];
    [super dealloc];
}


@end
