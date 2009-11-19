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

}

- (id)initWithAnnotation:(id <MKAnnotation>) annotation;

@end
