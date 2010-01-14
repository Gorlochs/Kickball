#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FriendPlacemark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString * url;
    NSString *userId;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * userId;

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (NSString *)subtitle;
- (NSString *)title;

@end
