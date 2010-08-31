//
//  TipListTableCell.m
//  Kickball
//
//  Created by scott bates on 8/31/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "TipListTableCell.h"


@implementation TipListTableCell

@synthesize tipName, tipDetail, userIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
		self.contentView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
		self.backgroundView.backgroundColor	= [UIColor colorWithWhite:0.92 alpha:1.0];


		CGRect frame = CGRectMake(8, 6, 34, 34);
        userIcon = [[TTImageView alloc] initWithFrame:frame];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"icon-default.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:3 topRight:3 bottomRight:3 bottomLeft:3] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
		
		iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-iconMask.png"]];
		iconBgImage.frame = CGRectMake(8, 6, 34, 34);
        [self addSubview:iconBgImage];
		
		tipName = [[UILabel alloc] initWithFrame:CGRectMake(54, 5, 240, 20)];
        tipName.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        tipName.font = [UIFont boldSystemFontOfSize:14.0];
        tipName.backgroundColor = [UIColor clearColor];
        tipName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        tipName.shadowOffset = CGSizeMake(1.0, 1.0);
        tipName.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:tipName];
        
        tipDetail = [[UILabel alloc] initWithFrame:CGRectMake(54, 20, 240, 20)];
        tipDetail.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        tipDetail.font = [UIFont systemFontOfSize:12.0];
        tipDetail.backgroundColor = [UIColor clearColor];
        tipDetail.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        tipDetail.shadowOffset = CGSizeMake(1.0, 1.0);
        tipDetail.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:tipDetail];
		
		topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
		topLineImage.frame = CGRectMake(0, 0, 320, 1);
		[self addSubview:topLineImage];
		
		// TODO: the origin.y should probably not be hard coded
		bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
		bottomLineImage.frame = CGRectMake(0, 47, 320, 1);
		[self addSubview:bottomLineImage];
		
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[tipName release];
	[tipDetail release];
	[bottomLineImage release];
	[topLineImage release];
	[iconBgImage release];
	[userIcon release];
    [super dealloc];
}


@end
