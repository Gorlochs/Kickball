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
    NSDateFormatter *twitterSearchDateFormatter;
}

@property (nonatomic, assign) NSDateFormatter *goodyDateFormatter;
@property (nonatomic, assign) NSDateFormatter *photoDateFormatter;
@property (nonatomic, assign) NSDateFormatter *twitterDateFormatter;
@property (nonatomic, assign) NSDateFormatter *twitterSearchDateFormatter;

+ (KickballAPI*) kickballApi;

- (NSMutableArray*) parsePhotosFromXML:(NSString*)responseString;
- (MockPhotoSource*) convertGoodiesIntoPhotoSource:(NSArray*)goodies withTitle:(NSString*)photoSourceTitle;
- (NSString*) convertDateToTimeUnitString:(NSDate*)dateToConvert;
- (NSDate*) convertToUTC:(NSDate*)sourceDate;

@end
