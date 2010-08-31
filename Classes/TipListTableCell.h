//
//  TipListTableCell.h
//  Kickball
//
//  Created by scott bates on 8/31/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"


@interface TipListTableCell : UITableViewCell {
	TTImageView *userIcon;
	UIImageView *topLineImage;
    UIImageView *bottomLineImage;
    UIImageView *iconBgImage;
	UILabel *tipName;
    UILabel *tipDetail;


}
@property (nonatomic, retain) UILabel *tipName;
@property (nonatomic, retain) UILabel *tipDetail;
@property (nonatomic, retain) TTImageView *userIcon;


@end
