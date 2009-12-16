//
//  FSMayor.h
//  Kickball
//
//  Created by Shawn Bernard on 12/15/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSUser.h"


@interface FSMayor : NSObject {
    FSUser *user;
    NSString *mayorCheckinMessage;
    NSInteger numCheckins;
    NSString *mayorTransitionType;
}

@property (nonatomic, retain) FSUser *user;
@property (nonatomic, retain) NSString *mayorCheckinMessage;
@property (nonatomic) NSInteger numCheckins;
@property (nonatomic, retain) NSString *mayorTransitionType;

@end
