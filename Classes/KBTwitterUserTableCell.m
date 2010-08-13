//
//  KBTwitterUserTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 4/28/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterUserTableCell.h"


@implementation KBTwitterUserTableCell

@synthesize userName;
@synthesize userIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        CGRect frame = CGRectMake(8, 6, 49, 49);
        userIcon = [[TTImageView alloc] initWithFrame:frame];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
        
        UIImageView *iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
        iconBgImage.frame = CGRectMake(6, 4, 54, 54);
        [self addSubview:iconBgImage];
		[iconBgImage release];
        
        userName = [[UILabel alloc] initWithFrame:CGRectMake(66, 19, 185, 20)];
        userName.textColor = [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:219.0/255.0 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:16.0];
        userName.backgroundColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:userName];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [userIcon release];
    [userName release];
    [super dealloc];
}


@end
