//
//  PlacesListTableViewCellv2.m
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlacesListTableViewCellv2.h"


@implementation PlacesListTableViewCellv2

@synthesize categoryIcon;
@synthesize venueName;
@synthesize venueAddress;
@synthesize specialImage;
@synthesize roundedTopCorners;
@synthesize roundedBottomCorners;
@synthesize labelWidth;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		labelWidth = 250;
		
        // Initialization code
		twoLine = NO;
        CGRect frame = CGRectMake(6, 6, 32, 32);
        categoryIcon = [[TTImageView alloc] initWithFrame:frame];
        categoryIcon.backgroundColor = [UIColor clearColor];
        categoryIcon.defaultImage = [UIImage imageNamed:@"blank.png"];
        categoryIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:categoryIcon];
        
        venueName = [[UILabel alloc] initWithFrame:CGRectMake(46, 5, 240, 20)];
        venueName.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        venueName.font = [UIFont boldSystemFontOfSize:14.0];
        venueName.backgroundColor = [UIColor clearColor];
        venueName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueName.shadowOffset = CGSizeMake(1.0, 1.0);
        venueName.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:venueName];
        
        venueAddress = [[UILabel alloc] initWithFrame:CGRectMake(46, 20, 240, 20)];
        venueAddress.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        venueAddress.font = [UIFont systemFontOfSize:12.0];
        venueAddress.backgroundColor = [UIColor clearColor];
        venueAddress.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueAddress.shadowOffset = CGSizeMake(1.0, 1.0);
        venueAddress.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:venueAddress];
        
        topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        topLineImage.frame = CGRectMake(0, 0, self.frame.size.width, 1);
		topLineImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:topLineImage];
        
        // TODO: the origin.y should probably not be hard coded
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        bottomLineImage.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
		bottomLineImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bottomLineImage];
        
        specialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"specialCorner.png"]];
        specialImage.frame = CGRectMake(298, 0, 22, 22);
        [self addSubview:specialImage];
		
		roundedTopCorners = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roundedTop.png"]];
		roundedTopCorners.frame = CGRectMake(0, 0, roundedTopCorners.frame.size.width, roundedTopCorners.frame.size.height);
		[self addSubview:roundedTopCorners];
		[self bringSubviewToFront:roundedTopCorners];
	
		roundedBottomCorners = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roundedBottom.png"]];
		roundedBottomCorners.frame = CGRectMake(0, self.frame.size.height - 3, roundedBottomCorners.frame.size.width, roundedBottomCorners.frame.size.height);
		[self addSubview:roundedBottomCorners];
		[self bringSubviewToFront:roundedBottomCorners];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	[categoryIcon setCenter:CGPointMake(categoryIcon.center.x, contentRect.size.height/2)];
	topLineImage.frame = CGRectMake(0, 0, contentRect.size.width, 1);
	bottomLineImage.frame = CGRectMake(0, contentRect.size.height - 1, contentRect.size.width, 1);
	if (twoLine) {
		UIFont *font = [UIFont boldSystemFontOfSize:14.0];
		int i;
		CGSize constraintSize = CGSizeMake(self.labelWidth, MAXFLOAT);
		for(i = 14; i > 10; i=i-1)
		{
			font = [font fontWithSize:i];// Set the new font size.
			
			// This step checks how tall the label would be with the desired font.
			CGSize labelSize = [venueName.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
			if(labelSize.height <= 40.0f) //If the label fits into your required height, it will break the loop
				break;
		}
		venueName.font = font;
		venueName.numberOfLines = 3;
		venueName.frame	= CGRectMake(46, contentRect.origin.y+5, self.labelWidth, 40);
		venueAddress.frame = CGRectMake(46, contentRect.origin.y+40, self.labelWidth, 20);
	} else {
		venueName.font = [UIFont boldSystemFontOfSize:14.0];
		venueName.numberOfLines = 1;
		venueName.frame	= CGRectMake(46, contentRect.origin.y+5, self.labelWidth, 20);
		venueAddress.frame = CGRectMake(46, contentRect.origin.y+20, self.labelWidth, 20);
	}
}

- (void)makeTwoLine {
	twoLine = YES;
}

- (void)makeOneLine {
	twoLine = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [categoryIcon release];
    
    [venueName release];
    [venueAddress release];
    
    [topLineImage release];
    [bottomLineImage release];
    [specialImage release];
	
	[roundedTopCorners release];
	[roundedBottomCorners release];
    [super dealloc];
}


@end
