//
//  TwLabel.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 1/5/10.
//  Copyright 2010 Codeminders. All rights reserved.
//

#import "TwLabel.h"

@implementation TwLabel

@synthesize mask = _mask;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    UIFont *sysFont = [UIFont systemFontOfSize:12];
    
    if (self.mask == nil) {
        CGRect frame = self.frame;
        
        frame.origin.x = frame.origin.y = 0;
        [self.text drawInRect:frame withFont:sysFont lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
    } else {
        UIFont *boldFont, *font;
        
        boldFont = [UIFont boldSystemFontOfSize:12];
        
        CGPoint offset = {0, 0};
        NSArray *words = [self.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        for (NSString *str in words) {
            NSRange pos = [str rangeOfString:self.mask options:NSCaseInsensitiveSearch];
            
            font = (pos.location == NSNotFound) ? sysFont : boldFont;
            
            if ([words indexOfObject:str] != ([words count] - 1))
                str = [str stringByAppendingString:@" "];
            
            CGSize wordSize = [str sizeWithFont:font];
            
            if ((offset.x + wordSize.width) > self.frame.size.width) {
                offset.x = 0;
                offset.y += 15;
            }
            [str drawAtPoint:offset withFont:font];
            offset.x += wordSize.width;
        }
    }
}

- (void)dealloc 
{
    self.mask = nil;
    [super dealloc];
}

@end
