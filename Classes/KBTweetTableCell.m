//
//  KBTweetTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 4/18/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTweetTableCell.h"
#import "KickballAPI.h"

#define TWITTER_DISPLAY_DATE_FORMAT @"LLL dd, hh:mm a"

@implementation KBTweetTableCell

@synthesize userIcon;
@synthesize userName;
@synthesize tweetText;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        CGRect frame = CGRectMake(8, 12, 49, 49);
        userIcon = [[TTImageView alloc] initWithFrame:frame];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
        
        iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
        iconBgImage.frame = CGRectMake(6, 10, 54, 54);
        [self addSubview:iconBgImage];
        
        userName = [[UILabel alloc] initWithFrame:CGRectMake(66, 5, 150, 20)];
        userName.textColor = [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:219.0/255.0 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:16.0];
        userName.backgroundColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:userName];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(216, 5, 100, 20)];
        dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:dateLabel];
        
        tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(66, 25, 250, 60)];
        tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        tweetText.font = [UIFont fontWithName:@"Georgia" size:12.0];
        tweetText.backgroundColor = [UIColor clearColor];
        tweetText.linksEnabled = YES;
        tweetText.numberOfLines = 0;
        //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:tweetText];
        
        topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        topLineImage.frame = CGRectMake(0, 0, self.frame.size.width, 1);
        [self addSubview:topLineImage];
        
        // TODO: the origin.y should probably not be hard coded
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        bottomLineImage.frame = CGRectMake(0, 1, self.frame.size.width, 1);
        [self addSubview:bottomLineImage];
    }
    return self;
}

- (void) setDateLabelWithDate:(NSDate*)theDate {
    //NSLog(@"label date: %@", theDate);
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:TWITTER_DISPLAY_DATE_FORMAT];
    dateLabel.text = [dateFormatter stringFromDate:theDate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [userIcon release];
    [userName release];
    [tweetText release];
    [dateLabel release];
    
    [topLineImage release];
    [bottomLineImage release];
    [iconBgImage release];
    [super dealloc];
}


@end
