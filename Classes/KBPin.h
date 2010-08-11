//
//  KBPin.h
//  Kickball
//
//  Created by Shawn Bernard on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KBPin : MKAnnotationView {
    NSString *title;
	id observer;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) id observer;

- (id)initWithAnnotation:(id <MKAnnotation>) annotation;

@end

