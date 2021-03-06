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
@synthesize numberOfTimeUnits;
@synthesize venueAddress;
@synthesize hasShoutAndCheckin;
@synthesize crownImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
		twoLine = NO;
        
                
        //CGRect frame = CGRectMake(8, 10, 49, 50);
		CGRect frame = CGRectMake(8, 10, 48, 48);
        userIcon = [[TTImageView alloc] initWithFrame:frame];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"icon-default.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:3 topRight:3 bottomRight:3 bottomLeft:3] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
		
		iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-iconMask.png"]];
		iconBgImage.frame = CGRectMake(8, 10, 48, 48);
        [self addSubview:iconBgImage];
        
        userName = [[UILabel alloc] initWithFrame:CGRectMake(66, 6, 220, 20)];
        userName.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:11.0];
        userName.backgroundColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
        userName.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:userName];
        
        venueName = [[UILabel alloc] initWithFrame:CGRectMake(66, 24, 250, 20)];
        venueName.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        venueName.font = [UIFont boldSystemFontOfSize:16.0];
        venueName.backgroundColor = [UIColor clearColor];
        venueName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueName.shadowOffset = CGSizeMake(1.0, 1.0);
        venueName.highlightedTextColor = [UIColor whiteColor];
        venueName.lineBreakMode = UILineBreakModeClip;
        [self addSubview:venueName];
        
        crownImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"place-mayorCrown.png"]];
        crownImage.frame = CGRectMake(20, 2, 13, 7);
		crownImage.hidden = YES;
        [self addSubview:crownImage];
        
        venueAddress = [[UILabel alloc] initWithFrame:CGRectMake(66, 42, 250, 20)];
        venueAddress.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        venueAddress.font = [UIFont boldSystemFontOfSize:11.0];
        venueAddress.backgroundColor = [UIColor clearColor];
        venueAddress.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueAddress.shadowOffset = CGSizeMake(1.0, 1.0);
        venueAddress.highlightedTextColor = [UIColor whiteColor];
        venueAddress.lineBreakMode = UILineBreakModeClip;
        [self addSubview:venueAddress];
		
		numberOfTimeUnits = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 37, 40)];
		numberOfTimeUnits.font = [UIFont systemFontOfSize:26.0];
		numberOfTimeUnits.shadowColor = [UIColor whiteColor];
		numberOfTimeUnits.shadowOffset = CGSizeMake(1.0, 1.0);
		numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
		numberOfTimeUnits.backgroundColor = [UIColor clearColor];
		numberOfTimeUnits.highlightedTextColor = [UIColor clearColor];
        [self addSubview:numberOfTimeUnits];
    }
    return self;
}



- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = [self.contentView bounds];
	[userIcon setCenter:CGPointMake(userIcon.center.x, contentRect.size.height/2)];
	[iconBgImage setCenter:CGPointMake(iconBgImage.center.x, contentRect.size.height/2)];
	[crownImage setCenter:CGPointMake(userIcon.center.x, userIcon.center.y-26)];
	[numberOfTimeUnits setCenter:CGPointMake(numberOfTimeUnits.center.x, contentRect.size.height/2)];
	if (twoLine) {
		if (hasShoutAndCheckin) {
			UIFont *font = [UIFont boldSystemFontOfSize:11.0];
			int i;
			CGSize constraintSize = CGSizeMake(200.0f, MAXFLOAT);
			for(i = 11; i > 8; i=i-1)
			{
				font = [font fontWithSize:i];// Set the new font size.
				
				// This step checks how tall the label would be with the desired font.
				CGSize labelSize = [venueAddress.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
				if(labelSize.height <= 50.0f) //If the label fits into your required height, it will break the loop
					break;
			}		
			venueAddress.font = font;
			userName.frame = CGRectMake(66, contentRect.origin.y+6, 200, 20);
			venueAddress.numberOfLines = 3;
			venueAddress.frame	= CGRectMake(66, contentRect.origin.y+42, 200, 50);
		} else { // just a shout
			UIFont *font = [UIFont boldSystemFontOfSize:16.0];
			int i;
			CGSize constraintSize = CGSizeMake(200.0f, MAXFLOAT);
			for(i = 16; i > 10; i=i-1)
			{
				font = [font fontWithSize:i];// Set the new font size.
				
				// This step checks how tall the label would be with the desired font.
				CGSize labelSize = [venueName.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
				if(labelSize.height <= 50.0f) //If the label fits into your required height, it will break the loop
					break;
			}		
			venueName.font = font;
			userName.frame = CGRectMake(66, contentRect.origin.y+6, 200, 20);
			venueName.numberOfLines = 3;
			venueName.frame	= CGRectMake(66, contentRect.origin.y+22, 200, 50);
			venueAddress.frame = CGRectMake(66, contentRect.origin.y+62, 200, 20);
		}
	} else {
		userName.frame = CGRectMake(66, contentRect.origin.y+6, 200, 20);
		venueName.numberOfLines = 1;
		venueName.font = [UIFont boldSystemFontOfSize:16.0];
		venueName.frame	= CGRectMake(66, contentRect.origin.y+24, 200, 20);
		venueAddress.frame = CGRectMake(66, contentRect.origin.y+42, 200, 20);
	}
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	if (selected) {
		numberOfTimeUnits.shadowColor = self.contentView.backgroundColor;
		numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		userName.shadowColor = self.contentView.backgroundColor;
        venueName.shadowColor = self.contentView.backgroundColor;
        venueAddress.shadowColor = self.contentView.backgroundColor;
	}else {
		numberOfTimeUnits.shadowColor = [UIColor whiteColor];
		numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
		userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueAddress.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];

	}
	
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (highlighted) {
		numberOfTimeUnits.shadowColor = self.contentView.backgroundColor;
		numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		userName.shadowColor = self.contentView.backgroundColor;
        venueName.shadowColor = self.contentView.backgroundColor;
        venueAddress.shadowColor = self.contentView.backgroundColor;
	}else {
		numberOfTimeUnits.shadowColor = [UIColor whiteColor];
		numberOfTimeUnits.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
		userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueAddress.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	}	
}


- (void)makeTwoLine {
	twoLine = YES;
}

- (void)makeOneLine {
	twoLine = NO;
}

- (void)dealloc {
    [userIcon release];
    [userName release];
    [venueName release];
    [venueAddress release];
	[iconBgImage release];
    [crownImage release];
	[numberOfTimeUnits release];
    [super dealloc];
}


@end
