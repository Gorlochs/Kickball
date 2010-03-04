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
}

@property (nonatomic, retain) NSArray *goodies;

@end
