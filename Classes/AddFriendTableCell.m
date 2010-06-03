//
//  AddFriendTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 5/25/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "AddFriendTableCell.h"


@implementation AddFriendTableCell

@synthesize addFriendButton;
@synthesize nameLabel;
@synthesize userIcon;
@synthesize iconBackground;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 3.0f, 220.0f, 60.0f)];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [nameLabel setTextColor:[UIColor blackColor]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setNumberOfLines:1];
        [self addSubview:nameLabel];
        
        iconBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconHolder.png"]];
        iconBackground.frame = CGRectMake(8, 8, 38, 38);
        [self addSubview:iconBackground];
        
        CGRect frame = CGRectMake(10, 10, 33, 34);
        userIcon = [[TTImageView alloc] initWithFrame:frame];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.clipsToBounds = YES;
        userIcon.contentMode = UIViewContentModeScaleToFill;
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:2 topRight:2 bottomRight:2 bottomLeft:2] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
        
        addFriendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        addFriendButton.frame = CGRectMake(250, 10, 33, 33);
        addFriendButton.showsTouchWhenHighlighted = YES;
        [addFriendButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
        //[addFriendButton addTarget:self action:@selector(displayProfile:) forControlEvents:UIControlEventTouchUpInside]; 
        [self addSubview:addFriendButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [nameLabel release];
    [addFriendButton release];
    [iconBackground release];
    [userIcon release];
    [super dealloc];
}


@end
