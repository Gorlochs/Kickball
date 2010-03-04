//
//  KBPhotoThumbnailCell.h
//  Kickball
//
//  Created by Shawn Bernard on 3/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBAsyncImageView.h"

@interface KBPhotoThumbnailCell : UITableViewCell {
    NSArray *goodies;
    IBOutlet UIButton *addPhotoButton;
    IBOutlet UIButton *firstTimePhotoButton;
    IBOutlet UIImageView *bgImage;
}

@property (nonatomic, retain) NSArray *goodies;
@property (nonatomic, retain) UIImageView *bgImage;
@property (nonatomic, retain) UIButton *addPhotoButton;
@property (nonatomic, retain) UIButton *firstTimePhotoButton;

@end
