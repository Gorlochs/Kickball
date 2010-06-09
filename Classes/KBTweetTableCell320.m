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

@synthesize userIcon;
@synthesize userName;
@synthesize tweetText;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.contentView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        userIcon = [[TTImageView alloc] initWithFrame:CGRectMake(10, 18, 34, 34)];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
        
		
        iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
		iconBgImage.frame = CGRectMake(8, 16, 38, 38);
        [self addSubview:iconBgImage];
		iconButt = [UIButton buttonWithType:UIButtonTypeCustom];
		[iconButt setFrame:CGRectMake(8, 16, 38, 38)];
		[iconButt retain];
		[iconButt addTarget:self action:@selector(pushToProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:iconButt];
        
        userName = [[UILabel alloc] init];
        userName.textColor = [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:219.0/255.0 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:16.0];
        userName.backgroundColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:userName];
        
        dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		dateLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:dateLabel];
        
		tweetText = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 25, 250, 70)];
		tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		tweetText.font = [UIFont fontWithName:@"Georgia" size:12.0];
		tweetText.backgroundColor = [UIColor clearColor];
		[self addSubview:tweetText];
		
		/*
        tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(66, 25, 250, 70)];
        tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        tweetText.font = [UIFont fontWithName:@"Georgia" size:12.0];
        tweetText.backgroundColor = [UIColor clearColor];
        tweetText.linksEnabled = YES;
        tweetText.numberOfLines = 0;
        //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:tweetText];
        */
		
        topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        [self addSubview:topLineImage];
        
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        [self addSubview:bottomLineImage];
	
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	userName.frame = CGRectMake(58, contentRect.origin.y+10, 150, 20);
	dateLabel.frame = CGRectMake(216, contentRect.origin.y+10, 100, 20);
	tweetText.center = CGPointMake(tweetText.center.x,(tweetText.frame.size.height/2)+32);
	topLineImage.frame = CGRectMake(0, 0, contentRect.size.width, 1);
	bottomLineImage.frame = CGRectMake(0, contentRect.size.height - 1, contentRect.size.width, 1);
	[iconButt setCenter:CGPointMake(27, contentRect.size.height/2)];
	[userIcon setCenter:CGPointMake(27, contentRect.size.height/2)];
	[iconBgImage setCenter:CGPointMake(27, contentRect.size.height/2)];
	
}

- (void) setDateLabelWithDate:(NSDate*)theDate {
    //DLog(@"label date: %@", theDate);
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:TWITTER_DISPLAY_DATE_FORMAT];
    dateLabel.text = [dateFormatter stringFromDate:theDate];
}

- (void) setDateLabelWithText:(NSString*)theDate {
    dateLabel.text = theDate;
	
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void) pushToProfile{
	UITableView *tv = (UITableView *) self.superview;
	UITableViewController *vc = (UITableViewController *) tv.dataSource;
	[(KBBaseTweetViewController*)vc viewUserProfile:userName.text];
}


- (void)dealloc {
    [userIcon release];
    [userName release];
	[iconButt retain];
    [tweetText release];
    [dateLabel release];
    
    [topLineImage release];
    [bottomLineImage release];
    [iconBgImage release];
    [super dealloc];
}


@end
