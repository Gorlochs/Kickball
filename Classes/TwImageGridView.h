//
//  TwImageGridView.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 12/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const float kImageGridThumbnailWidth;
extern const float kImageGridThumbnailHeight;

@interface TwImageGridView : UIView {
@private
    NSArray *_images;
    UIActivityIndicatorView *_indicator;
}

@property (nonatomic, retain) NSArray *images;

- (void)startIndicator;
- (void)stopIndicator;

@end


// Proxy class
@interface TwImageGridViewProxy : TwImageGridView {
@private
    NSArray *_imageLinks;
}

@property (nonatomic, retain) NSArray *imageLinks;

- (CGSize)calculateSize:(float)maxWidth;

@end
