//
//  TipListTableCell.m
//  Kickball
//
//  Created by scott bates on 8/31/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "TipListTableCell.h"


@implementation TipListTableCell

@synthesize tipName, tipDetail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
			
		tipName = [[UILabel alloc] initWithFrame:CGRectMake(54, 5, 240, 20)];
        tipName.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        tipName.font = [UIFont boldSystemFontOfSize:14.0];
        tipName.backgroundColor = [UIColor clearColor];
        tipName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        tipName.shadowOffset = CGSizeMake(1.0, 1.0);
        tipName.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:tipName];
        
        tipDetail = [[UILabel alloc] initWithFrame:CGRectMake(54, 20, 240, 20)];
        tipDetail.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        tipDetail.font = [UIFont systemFontOfSize:12.0];
        tipDetail.backgroundColor = [UIColor clearColor];
        tipDetail.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        tipDetail.shadowOffset = CGSizeMake(1.0, 1.0);
        tipDetail.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:tipDetail];
		
    }
    return self;
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	CGRect smallerImageFrame = CGRectMake(4, (contentRect.size.height-34)/2, 34, 34);
	userIcon.frame = smallerImageFrame;
	iconButt.frame = smallerImageFrame;
	iconBgImage.frame = smallerImageFrame;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[tipName release];
	[tipDetail release];
    [super dealloc];
}


@end
