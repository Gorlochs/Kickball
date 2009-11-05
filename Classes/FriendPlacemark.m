#import "FriendPlacemark.h"

@implementation FriendPlacemark
@synthesize coordinate;

- (NSString *)subtitle{
	return @"Put some text here";
}
- (NSString *)title{
	return @"Parked Location";
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}
@end