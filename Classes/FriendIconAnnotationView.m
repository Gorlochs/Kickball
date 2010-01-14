//
//  FriendIconAnnotationView.m
//  Kickball
//
//  Created by David Evans on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FriendIconAnnotationView.h"
#import "Utilities.h"
#import "ProfileViewController.h"
#import "FriendsMapViewController.h"

#define kHeight 32
#define kWidth 32
#define kBorder 2

@implementation FriendIconAnnotationView
@synthesize imageView, userData, title, subtitle, url, userId;

- (id)initWithAnnotation:(id )annotation reuseIdentifier:(NSString *)reuseIdentifier andImageUrl:(NSString *) inUrl{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	self.frame = CGRectMake(0, 0, kWidth, kHeight);
	self.backgroundColor = [UIColor whiteColor];
	if(inUrl){
//		NSURL *imgUrl = [NSURL URLWithString:inUrl];
//		NSData *data = [NSData dataWithContentsOfURL:imgUrl];
//		UIImage *img = [[UIImage alloc] initWithData:data];
		
		imageView = [[UIImageView alloc] initWithImage:[[Utilities sharedInstance] getCachedImage:inUrl]];
		imageView.frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kWidth - 2 * kBorder);
		[self addSubview:imageView];
//        [img release];
	}
		
	return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
//    profileController.userId = userId;
//    [((FriendsMapViewController*)self.superview.superview.superview.superview.superview.superview.superview).navigationController pushViewController:profileController animated:YES];
//    [profileController release];
//}

-(void) dealloc
{
	[imageView release];
	[super dealloc];
}

@end