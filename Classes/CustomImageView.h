//
//  CustomImageView.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/14/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CIDefaultFrameType,
    CIRoudrectFrameType
} CustomImageViewFrameType;

@interface CustomImageView : UIView
{
    UIImage *image;
    int frameType;
}

@property (nonatomic, retain) UIImage* image;
@property (nonatomic) int frameType;

@end

@interface ActiveImageView : CustomImageView
{
    UIActivityIndicatorView *_indictator;
    NSString                *_imageUrl;
    unsigned                 _width;
    unsigned                 _height;
}

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic) unsigned width;
@property (nonatomic) unsigned height;

- (void)update;

- (void)start;
- (void)stop;

@end
