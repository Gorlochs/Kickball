//
//  KBTweetTableCell320.m
//  Kickball
//
//  Created by scott bates on 6/8/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBTweetTableCell320.h"
#import "KickballAPI.h"
#import "KBBaseTweetViewController.h"

@implementation KBTweetTableCell320

@synthesize userName;
@synthesize tweetText;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        userName = [[UILabel alloc] init];
        userName.textColor = [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:219.0/255.0 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:16.0];
        userName.backgroundColor = [UIColor clearColor];
		userName.highlightedTextColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:userName];
        
        dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.highlightedTextColor = [UIColor clearColor];
        dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		dateLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:dateLabel];
		
        tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(58, 0, 250, 70)];
        tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        tweetText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        tweetText.backgroundColor = [UIColor clearColor];
		tweetText.labelHighlightedTextColor = [UIColor whiteColor];
        tweetText.linksEnabled = NO;
        tweetText.numberOfLines = 0;
        [self addSubview:tweetText];
	
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	userName.frame = CGRectMake(58, contentRect.origin.y+8, 150, 20);
	dateLabel.frame = CGRectMake(216, contentRect.origin.y+8, 100, 20);
	tweetText.center = CGPointMake(tweetText.center.x,(tweetText.frame.size.height/2)+32);
}

- (void) setDateLabelWithDate:(NSDate*)theDate {
    //DLog(@"label date: %@", theDate);
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
	if (selected) {
		//dateLabel.textColor = [UIColor whiteColor];
		dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        dateLabel.shadowOffset = CGSizeMake(0.0, 0.0);
		userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        userName.shadowOffset = CGSizeMake(0.0, 0.0);
	}else {
		//dateLabel.textColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
		dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
	}
	
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (highlighted) {
		//dateLabel.textColor = [UIColor whiteColor];
		dateLabel.shadowColor = [UIColor colorWithWhite:0.75 alpha:1.0];
        //dateLabel.shadowOffset = CGSizeMake(0.0, 0.0);
		userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        userName.shadowOffset = CGSizeMake(0.0, 0.0);
	}else {
		//dateLabel.textColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
		dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
	}	
}

- (void) pushToProfile{
	UITableView *tv = (UITableView *) self.superview;
	UITableViewController *vc = (UITableViewController *) tv.dataSource;
	[(KBBaseTweetViewController*)vc viewOtherUserProfile:userName.text];
}


- (void)dealloc {
    [userName release];
    [tweetText release];
    [dateLabel release];
    [super dealloc];
}


@end
