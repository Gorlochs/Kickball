#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface FriendPlacemark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString * url;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (NSString *)subtitle;
- (NSString *)title;
@property (nonatomic, retain) NSString * url;

@end
