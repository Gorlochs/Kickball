//
//  KBTwitterUserTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 4/28/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterUserTableCell.h"


@implementation KBTwitterUserTableCell

@synthesize userName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        userName = [[UILabel alloc] initWithFrame:CGRectMake(66, 19, 185, 20)];
        userName.textColor = [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:219.0/255.0 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:16.0];
        userName.backgroundColor = [UIColor clearColor];
        userName.highlightedTextColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
		
		caret = [[UIImageView alloc] initWithFrame:CGRectMake(300, 0, 8, 11)];
		[caret setImage:[UIImage imageNamed:@"btn-arrow01.png"]];
		[self addSubview:caret];
        [self addSubview:userName];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	caret.center = CGPointMake(caret.center.x,(contentRect.size.height/2));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[caret release];
    [userName release];
    [super dealloc];
}


@end
