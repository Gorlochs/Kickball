//
//  TableSectionHeaderView.h
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableSectionHeaderView : UIView {
    UILabel *leftHeaderLabel;
    UILabel *rightHeaderLabel;
    
    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
}

@property (nonatomic, retain) UILabel *leftHeaderLabel;
@property (nonatomic, retain) UILabel *rightHeaderLabel;

@end
