//
//  FSCategory.h
//  Kickball
//
//  Created by Shawn Bernard on 3/13/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSCategory : NSObject <NSCoding> {
    NSString *categoryId;
    NSString *fullPathName;
    NSString *nodeName;
    NSString *iconUrl;
    NSArray *subcategories;
}

@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *fullPathName;
@property (nonatomic, retain) NSString *nodeName;
@property (nonatomic, retain) NSString *iconUrl;
@property (nonatomic, retain) NSArray *subcategories;

- (NSString*) highResolutionIconUrl;

@end
