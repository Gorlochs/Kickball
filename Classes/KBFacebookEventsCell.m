//
//  KBFacebookEventsCell.m
//  Kickball
//
//  Created by scott bates on 6/17/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookEventsCell.h"
#import "FacebookProxy.h"

@implementation KBFacebookEventsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		eventHost = [[UILabel alloc] init];
		eventHost.textColor = [UIColor colorWithRed:83/255.0 green:134/255.0 blue:225/255.0 alpha:1.0];
        eventHost.font = [UIFont systemFontOfSize:12.0];
        eventHost.backgroundColor = [UIColor clearColor];
        eventHost.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        eventHost.shadowOffset = CGSizeMake(1.0, 1.0);
		eventHost.textAlignment = UITextAlignmentLeft;
        [self addSubview:eventHost];
		
		eventName = [[UILabel alloc] init];
		eventName.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
        eventName.font = [UIFont boldSystemFontOfSize:14.0];
        eventName.backgroundColor = [UIColor clearColor];
        eventName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        eventName.shadowOffset = CGSizeMake(1.0, 1.0);
		eventName.textAlignment = UITextAlignmentLeft;
        [self addSubview:eventName];
		
		eventTime = [[UILabel alloc] init];
		eventTime.textColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
        eventTime.font = [UIFont systemFontOfSize:18.0];
        eventTime.backgroundColor = [UIColor clearColor];
        eventTime.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        eventTime.shadowOffset = CGSizeMake(1.0, 1.0);
		eventTime.textAlignment = UITextAlignmentLeft;
        [self addSubview:eventTime];
		
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
	
	topLineImage.frame = CGRectMake(0, 0, contentRect.size.width, 1);
	bottomLineImage.frame = CGRectMake(0, contentRect.size.height - 1, contentRect.size.width, 1);
	
	eventHost.frame = CGRectMake(10, 10, 238, 18);
	eventName.frame = CGRectMake(10, 28, 238, 22);
	eventTime.frame = CGRectMake(250, 10, 70, 40);
	
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)populate:(NSDictionary*)event{

	eventHost.text = [[event objectForKey:@"host"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	eventName.text = [[event objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSDate *fbEventDate = [NSDate dateWithTimeIntervalSince1970:[(NSString*)[event objectForKey:@"start_time"] intValue]];
	[fbEventDate addTimeInterval:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
	eventTime.text = [[FacebookProxy fbEventCellTimeFormatter] stringFromDate:fbEventDate];
}

- (void)dealloc {
    [super dealloc];
}


@end
