//
//  PlacePeopleHereTableCell.m
//  Kickball
//
//  Created by scott bates on 9/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlacePeopleHereTableCell.h"


@implementation PlacePeopleHereTableCell
@synthesize textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		textLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 5, 240, 34)];
        textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        textLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:textLabel];
		
		caret = [[UIImageView alloc] initWithFrame:CGRectMake(300, 0, 8, 11)];
		[caret setImage:[UIImage imageNamed:@"btn-arrow01.png"]];
		[self addSubview:caret];
		
		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	textLabel.center = CGPointMake(textLabel.center.x,(contentRect.size.height/2));
	caret.center = CGPointMake(caret.center.x,(contentRect.size.height/2));

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[caret release];
	[textLabel release];
	[super dealloc];
}


@end
