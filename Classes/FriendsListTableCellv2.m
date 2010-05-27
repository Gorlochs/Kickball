//
//  FriendsListTableCellv2.m
//  Kickball
//
//  Created by Shawn Bernard on 3/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendsListTableCellv2.h"


@implementation FriendsListTableCellv2

@synthesize userIcon;
@synthesize userName;
@synthesize venueName;
@synthesize venueAddress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        CGRect frame = CGRectMake(8, 10, 49, 49);
        userIcon = [[TTImageView alloc] initWithFrame:frame];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
        
        iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
        iconBgImage.frame = CGRectMake(6, 8, 54, 54);
        [self addSubview:iconBgImage];
        
        userName = [[UILabel alloc] initWithFrame:CGRectMake(66, 6, 200, 20)];
        userName.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:11.0];
        userName.backgroundColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
        userName.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:userName];
        
        venueName = [[UILabel alloc] initWithFrame:CGRectMake(66, 24, 200, 20)];
        venueName.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        venueName.font = [UIFont boldSystemFontOfSize:16.0];
        venueName.backgroundColor = [UIColor clearColor];
        venueName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueName.shadowOffset = CGSizeMake(1.0, 1.0);
        venueName.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:venueName];
        
        venueAddress = [[UILabel alloc] initWithFrame:CGRectMake(66, 42, 200, 20)];
        venueAddress.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        venueAddress.font = [UIFont boldSystemFontOfSize:11.0];
        venueAddress.backgroundColor = [UIColor clearColor];
        venueAddress.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueAddress.shadowOffset = CGSizeMake(1.0, 1.0);
        venueAddress.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:venueAddress];
        
        topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        topLineImage.frame = CGRectMake(0, 0, self.frame.size.width, 1);
        [self addSubview:topLineImage];
        
        // TODO: the origin.y should probably not be hard coded
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        bottomLineImage.frame = CGRectMake(0, 71, self.frame.size.width, 1);
        [self addSubview:bottomLineImage];
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
    [venueName release];
    [venueAddress release];
    [topLineImage release];
    [bottomLineImage release];
    [super dealloc];
}


@end
