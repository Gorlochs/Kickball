//
//  TwImageGridView.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 12/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "TwImageGridView.h"
#import "CustomImageView.h"

const float kImageGridThumbnailWidth = 84.0f;
const float kImageGridThumbnailHeight = 84.0f;

@implementation TwImageGridView

@synthesize images = _images;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}
/*
- (void)drawRect:(CGRect)rect 
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    if (_images == nil)
        return;
    
    // Remove all child subviews from grid
    for (UIView *child in self.subviews) {
        [child removeFromSuperview];
    }
    
    float parent_width = self.frame.size.width;
    
    CGRect frame = CGRectMake(0, 0, kImageGridThumbnailWidth, kImageGridThumbnailHeight);
    // Set new images
    for (UIImage *image in _images) {
        CustomImageView *imageView = [[CustomImageView alloc] initWithFrame:CGRectZero];

        imageView.frameType = CIDefaultFrameType;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = image;
        
        imageView.frame = frame;
        [self addSubview:imageView];
        
        if (frame.origin.x + frame.size.width > parent_width) {
            frame.origin.x = 0;
            frame.origin.y += kImageGridThumbnailHeight;
        }
        
        frame.origin.x += kImageGridThumbnailWidth + 2;
        [imageView release];
    }
    
    float max_height = frame.origin.y + kImageGridThumbnailHeight;
    
    frame = self.frame;
    frame.size.height = max_height;
    self.frame = frame;
}

- (void)dealloc 
{
    [_indicator release];
    
    self.images = nil;
    [super dealloc];
}

- (void)setImages:(NSArray*)newImages
{
    if (_images != newImages)
    {
        [newImages retain];
        if (_images)
            [_images release];
        _images = newImages;
        
        [self setNeedsLayout];
    }
}

- (void)startIndicator
{
    if ([_indicator isAnimating] == NO)
    {
        CGRect ind_rect = _indicator.frame;
        
        ind_rect.origin.x = (self.frame.size.width - ind_rect.size.width) / 2;
        ind_rect.origin.y = (self.frame.size.height - ind_rect.size.height) / 2;
        
        _indicator.frame = ind_rect;
        [self addSubview:_indicator];
        [_indicator startAnimating];
    }
}

- (void)stopIndicator
{
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
}

@end



//------------------------------------------------------------------
@implementation TwImageGridViewProxy

@synthesize imageLinks = _imageLinks;

- (void)dealloc
{
    self.imageLinks = nil;
    [super dealloc];
}

- (void)setImages:(NSArray*)newImages
{
}

- (NSArray*)images
{
    return nil;
}

- (CGSize)calculateSize:(float)maxWidth
{
    CGSize size = CGSizeZero;
    
    if (_imageLinks) {
        int count = [_imageLinks count];
        
        int cols = (int)(maxWidth / (kImageGridThumbnailWidth + 2.));
        int rows = count / cols;
        if (count % cols > 0)
            rows++;
        
        size.width = cols * (kImageGridThumbnailWidth + 2.);
        size.height = rows * (kImageGridThumbnailHeight + 2.);
    }
    return size;
}

@end
