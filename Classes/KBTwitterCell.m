//
//  KBTwitterCell.m
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterCell.h"


@implementation KBTwitterCell

@synthesize tweetLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        tweetLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(10.0f, 3.0f, 300.0f, 60.0f)];
        [tweetLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [tweetLabel setTextColor:[UIColor blackColor]];
        [tweetLabel setBackgroundColor:[UIColor clearColor]];
        [tweetLabel setNumberOfLines:0];
        [self addSubview:tweetLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [tweetLabel release];
    [super dealloc];
}


@end
