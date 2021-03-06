//
//  FSCategory.m
//  Kickball
//
//  Created by Shawn Bernard on 3/13/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FSCategory.h"


@implementation FSCategory

@synthesize categoryId;
@synthesize fullPathName;
@synthesize nodeName;
@synthesize iconUrl;
@synthesize subcategories;

- (NSString*) description {
    return [NSString stringWithFormat:@"(CATEGORY : categoryId=%@ ; nodeName=%@ ; iconUrl=%@ ; fullPathName=%@ ; subcategories=%@)", categoryId, nodeName, iconUrl, fullPathName, subcategories];
}

- (NSString*) highResolutionIconUrl {
	return [self.iconUrl stringByReplacingOccurrencesOfString:@".png" withString:@"_64.png"];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: categoryId forKey:@"categoryId"]; 
    [coder encodeObject: fullPathName forKey:@"fullPathName"]; 
    [coder encodeObject: nodeName forKey:@"nodeName"]; 
    [coder encodeObject: iconUrl forKey:@"iconUrl"];  
    [coder encodeObject: subcategories forKey:@"subcategories"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setCategoryId: [coder decodeObjectForKey:@"categoryId"]]; 
        [self setFullPathName: [coder decodeObjectForKey:@"fullPathName"]];  
        [self setNodeName: [coder decodeObjectForKey:@"nodeName"]];  
        [self setIconUrl: [coder decodeObjectForKey:@"iconUrl"]];   
        [self setSubcategories:[coder decodeObjectForKey:@"subcategories"]]; 
    } 
    return self; 
} 
-(void)dealloc{
	[categoryId release];
	[fullPathName release];
	[nodeName release];
	[iconUrl release];
	[subcategories release];
	[super dealloc];
}
@end
