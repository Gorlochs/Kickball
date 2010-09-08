//
//  CoreTableCellWithProfilePic.m
//  Kickball
//
//  Created by scott bates on 9/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "CoreTableCellWithProfilePic.h"


@implementation CoreTableCellWithProfilePic
@synthesize userIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		userIcon = [[TTImageView alloc] initWithFrame:CGRectMake(4, 18, 48, 48)];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"icon-default.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
        
		
        iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-iconMask.png"]];
		iconBgImage.frame = CGRectMake(4, 18, 48, 48);
        [self addSubview:iconBgImage];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = [self.contentView bounds];
	[userIcon setCenter:CGPointMake(userIcon.center.x, contentRect.size.height/2)];
	[iconBgImage setCenter:CGPointMake(iconBgImage.center.x, contentRect.size.height/2)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[userIcon release];
	[iconBgImage release];
    [super dealloc];
}


@end
