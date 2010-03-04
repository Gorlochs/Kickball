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

@synthesize goodies, bgImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void) setGoodies:(NSArray *)theGoodies {
    goodies = [theGoodies retain];
    [theGoodies release];
    
//    int i = 0;
//    for (KBGoody *goody in goodies) {
//        CGRect frame = CGRectMake(i*74, 0, 74, 74);
//        TTImageView *ttImage = [[TTImageView alloc] initWithFrame:frame];
//        ttImage.urlPath = goody.mediumImagePath;
//        ttImage.clipsToBounds = YES;
//        ttImage.contentMode = UIViewContentModeCenter;
//        [self addSubview:ttImage];
//        
//        UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//        button.frame = CGRectMake(i*74, 0, 74, 74);
//        button.showsTouchWhenHighlighted = YES;
//        [button addTarget:self action:@selector(displayImages:) forControlEvents:UIControlEventTouchUpInside]; 
//        //[buttonArray addObject:button];
//        [self addSubview:button];
//        [button release];
//        i++;
//        if (i > 9) {
//            // TODO: add 'more' button here
//            break;
//        }
//    }
}

- (void) displayImages:(id)sender {
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [goodies release];
    [super dealloc];
}


@end
