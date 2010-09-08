//
//  CoreTableCell.m
//  Kickball
//
//  Created by scott bates on 9/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "CoreTableCell.h"


@implementation CoreTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		[self.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
		[self.contentView setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
        // Initialization code
		topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        [self addSubview:topLineImage];
        
		topPressedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellPressedTop.png"]];
		[topPressedImage setHidden:YES];
        [self addSubview:topPressedImage];
		
        // TODO: the origin.y should probably not be hard coded
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
	topPressedImage.frame = CGRectMake(0, 0, contentRect.size.width, 3);
	bottomLineImage.frame = CGRectMake(0, contentRect.size.height - 1, contentRect.size.width, 1);
	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	if (selected) {
		[topPressedImage setHidden:NO];
		[topLineImage setHidden:YES];
		[self.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
		[self.contentView setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
	}else {
		[topPressedImage setHidden:YES];
		[topLineImage setHidden:NO];
		[self.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
		[self.contentView setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
	}
	
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (highlighted) {
		[topPressedImage setHidden:NO];
		[topLineImage setHidden:YES];
		[self.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
		[self.contentView setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
	}else {
		[topPressedImage setHidden:YES];
		[topLineImage setHidden:NO];
		[self.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
		[self.contentView setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
	}
	
}


- (void)dealloc {
	[topLineImage release];
    [bottomLineImage release];
	[topPressedImage release];
    [super dealloc];
}


@end
