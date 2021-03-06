//
//  KBTweetTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 4/18/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTweetTableCell.h"
#import "KickballAPI.h"


@implementation KBTweetTableCell

@synthesize userName;
@synthesize tweetText;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
               
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
		dateLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:dateLabel];
        
        tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(66, 25, 250, 70)];
        tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        tweetText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        tweetText.backgroundColor = [UIColor clearColor];
        tweetText.linksEnabled = NO;
        tweetText.numberOfLines = 0;
        //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:tweetText];
	}
    return self;
}

- (void) setDateLabelWithDate:(NSDate*)theDate {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:TWITTER_DISPLAY_DATE_FORMAT];
    dateLabel.text = [dateFormatter stringFromDate:theDate];
    [dateFormatter release];
}

- (void) setDateLabelWithText:(NSString*)theDate {
    dateLabel.text = theDate;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [userName release];
    [tweetText release];
    [dateLabel release];
    [super dealloc];
}


@end
