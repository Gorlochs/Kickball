//
//  PlacePeopleHereTableCell.m
//  Kickball
//
//  Created by scott bates on 9/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlacePeopleHereTableCell.h"


@implementation PlacePeopleHereTableCell
@synthesize textLabel, imageIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		// Initialization code
		self.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
		self.contentView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
		self.backgroundView.backgroundColor	= [UIColor colorWithWhite:0.92 alpha:1.0];
		
		
		CGRect frame = CGRectMake(8, 5, 34, 34);
        imageIcon = [[TTImageView alloc] initWithFrame:frame];
        imageIcon.backgroundColor = [UIColor clearColor];
        imageIcon.defaultImage = [UIImage imageNamed:@"icon-default.png"];
        imageIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:3 topRight:3 bottomRight:3 bottomLeft:3] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:imageIcon];
		
		iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-iconMask.png"]];
		iconBgImage.frame = CGRectMake(8, 5, 34, 34);
        [self addSubview:iconBgImage];
		
		textLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 5, 240, 34)];
        textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        textLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:textLabel];
		
		topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
		topLineImage.frame = CGRectMake(0, 0, 320, 1);
		[self addSubview:topLineImage];
		
		// TODO: the origin.y should probably not be hard coded
		bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
		bottomLineImage.frame = CGRectMake(0, 43, 320, 1);
		[self addSubview:bottomLineImage];
		
		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	imageIcon.center = CGPointMake(imageIcon.center.x,(contentRect.size.height/2));
	iconBgImage.center = CGPointMake(iconBgImage.center.x,(contentRect.size.height/2));
	textLabel.center = CGPointMake(textLabel.center.x,(contentRect.size.height/2));
	topLineImage.frame = CGRectMake(0, 0, contentRect.size.width, 1);
	bottomLineImage.frame = CGRectMake(0, contentRect.size.height - 1, contentRect.size.width, 1);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[textLabel release];
	[imageIcon release];
	[iconBgImage release];
	[topLineImage release];
	[bottomLineImage release];
    [super dealloc];
}


@end
