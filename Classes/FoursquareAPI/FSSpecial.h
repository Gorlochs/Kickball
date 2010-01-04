//
//  FSSpecial.h
//  Kickball
//
//  Created by Shawn Bernard on 12/19/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//
//  Example XML:
//      <special>
//          <id>24</id>
//          <type>mayor</type>
//          <message>If you're the mayor of Whiffie's show the pie siren at the window and get $1 off your first three pies/day. Bring your friends!</message>
//          <venue>
//              <id>60578</id>
//              <name>Whiffies Fried Pies</name>
//          </venue>
//      </special>

#import <Foundation/Foundation.h>
#import "FSVenue.h"

@interface FSSpecial : NSObject <NSCoding> {
    NSString *specialId;
    NSString *type;
    NSString *message;
    FSVenue  *venue;
}

@property (nonatomic, retain) NSString *specialId;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) FSVenue  *venue;

@end
