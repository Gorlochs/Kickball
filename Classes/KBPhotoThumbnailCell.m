//
//  KBPhotoThumbnailCell.m
//  Kickball
//
//  Created by Shawn Bernard on 3/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBPhotoThumbnailCell.h"
#import "KBGoody.h"
#import "Three20/Three20.h"

@implementation KBPhotoThumbnailCell

@synthesize goodies, bgImage, firstTimePhotoButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [goodies release];
    [firstTimePhotoButton release];
    [bgImage release];
    [super dealloc];
}


@end
