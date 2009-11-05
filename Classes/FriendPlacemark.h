#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface FriendPlacemark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (NSString *)subtitle;
- (NSString *)title;

@end
