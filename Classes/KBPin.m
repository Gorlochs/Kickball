//
//  KBPin.m
//  Kickball
//
//  Created by Shawn Bernard on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBPin.h"


@implementation KBPin

@synthesize title;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation
{
    self = [super initWithAnnotation:annotation reuseIdentifier:@"CustomId"];
    
    if (self)        
    {
        UIImage*    theImage = [UIImage imageNamed:@"pin01.png"];
        
        if (!theImage)
            return nil;
        
        self.image = theImage;
    }    
    return self;
}

- (void) dealloc {
    [title release];
    [super dealloc];
}

@end

