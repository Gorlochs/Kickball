//
//  KickballAPI.h
//  Kickball
//
//  Created by Shawn Bernard on 3/31/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockPhotoSource.h"

@interface KickballAPI : NSObject {
    NSDateFormatter *goodyDateFormatter;
    NSDateFormatter *photoDateFormatter;
    NSDateFormatter *twitterDateFormatter;
}

@property (nonatomic, retain) NSDateFormatter *photoDateFormatter;
@property (nonatomic, retain) NSDateFormatter *twitterDateFormatter;

+ (KickballAPI*) kickballApi;

- (NSMutableArray*) parsePhotosFromXML:(NSString*)responseString;
- (MockPhotoSource*) convertGoodiesIntoPhotoSource:(NSArray*)goodies withTitle:(NSString*)photoSourceTitle;
- (NSString*) convertDateToTimeUnitString:(NSDate*)dateToConvert;
- (NSDate*) convertToUTC:(NSDate*)sourceDate;

@end
