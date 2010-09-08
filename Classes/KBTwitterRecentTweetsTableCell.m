//
//  KBTwitterRecentTweetsTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 5/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterRecentTweetsTableCell.h"
#import "Utilities.h"


@implementation KBTwitterRecentTweetsTableCell

@synthesize tweetText;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	   if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
        // Initialization code
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(216, 5, 100, 20)];
        dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:dateLabel];
        
        tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20, 15, 270, 80)];
        tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        tweetText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        tweetText.backgroundColor = [UIColor clearColor];
        tweetText.linksEnabled = NO;
        tweetText.numberOfLines = 0;
        //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:tweetText];
        
        
//        retweetButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//        retweetButton.frame = CGRectMake(250, self.frame.size.height - 10, 92, 39);
//        retweetButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        retweetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//        [retweetButton setImage:[UIImage imageNamed:@"retweet_small.png"] forState:UIControlStateNormal];
//        //[retweetButton addTarget:self action:@selector(retweet:) forControlEvents:UIControlEventTouchUpInside]; 
//        [self addSubview:retweetButton];
    }
    return self;
}

- (void) setDateLabelWithDate:(NSDate*)theDate {
    //DLog(@"label date: %@", theDate);
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:TWITTER_DISPLAY_DATE_FORMAT];
    dateLabel.text = [dateFormatter stringFromDate:theDate];
    [dateFormatter release];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [tweetText release];
    [dateLabel release];
    [super dealloc];
}

@end
