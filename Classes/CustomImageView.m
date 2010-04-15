//
//  CustomImageView.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/14/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "CustomImageView.h"
#import "ImageLoader.h"
#import "util.h"

@implementation CustomImageView

@synthesize image;
@synthesize frameType;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code
        self.frameType = CIRoudrectFrameType;
        self.image = nil;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    if (self.frameType == CIRoudrectFrameType)
    {
        float radius = 5.0f;

        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
        CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
        CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
        CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
        CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
        CGContextClosePath(context);
        CGContextClip(context);
    }
    
    // Draw image
    if (self.image)
        [self.image drawAtPoint:CGPointMake(0, 0)];
}


- (void)dealloc 
{
    if (image)
        [image release];
    [super dealloc];
}

- (void)setImage:(UIImage *)theImage
{
    if (image)
        [image release];
    image = [theImage retain];
    [self setNeedsDisplay];
}

- (void)setFrameType:(int)ftype
{
    frameType = ftype;
    [self setNeedsDisplay];
}

@end

/*****************************************************************
 *
 * ActiveImageView class implementation
 *
 *****************************************************************/
@implementation ActiveImageView

@synthesize imageUrl = _imageUrl;
@synthesize width = _width;
@synthesize height = _height;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _indictator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    return self;
}

- (void)dealloc
{
    [_indictator release];
    [super dealloc];
}

- (void)update
{
    if (self.imageUrl == nil)
        return;
    
    [self addSubview:_indictator];
    [_indictator startAnimating];
    
    //UIImage *theImage = [[ImageLoader sharedLoader] imageWithURL:self.imageUrl];
    //if (theImage.size.width > self.width || theImage.size.height > self.height)
    //    theImage = imageScaledToSize(theImage, self.width);
    //self.image = theImage;
    //CGSize avatarViewSize = CGSizeMake(48, 48);
    
    
    //[self performSelectorInBackground:@selector(loadInBackground:) withObject:self];
    
    //self.image = loadAndScaleImage(self.imageUrl, avatarViewSize);
    
    //[_indictator stopAnimating];
    //[_indictator removeFromSuperview];
}

- (void)loadInBackground:(id)object
{
    CGSize avatarViewSize = CGSizeMake(48, 48);
    self.image = loadAndScaleImage(self.imageUrl, avatarViewSize);
    [_indictator stopAnimating];
    [_indictator removeFromSuperview];
}

- (void)start
{
    [self addSubview:_indictator];
    [_indictator startAnimating];
}

- (void)stop
{
    [_indictator stopAnimating];
    [_indictator removeFromSuperview];
}

@end
