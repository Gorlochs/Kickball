//
//  Profile.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/20/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject {
	long long	  _id;
	NSString	* _comments;
	NSString	* _description;
	NSString	* _favorites;
	NSString	* _firstName;
	NSString	* _friends;
	NSString	* _homepage;
	NSString	* _mapTypeForProfile;
	NSString	* _photos;
	NSString	* _profileImage;
	NSData   	* _profileImageData;
	NSString	* _screenName;
	long long     _serviceId;
	NSString	* _settings;
	NSString	* _views;
}

@property long long  						id;
@property long long  						serviceId;
@property (retain, nonatomic) NSString *	comments;
@property (retain, nonatomic) NSString *	description;
@property (retain, nonatomic) NSString *	favorites;
@property (retain, nonatomic) NSString *	firstName;
@property (retain, nonatomic) NSString *	friends;
@property (retain, nonatomic) NSString *	homepage;
@property (retain, nonatomic) NSString *	mapTypeForProfile;
@property (retain, nonatomic) NSString *	photos;
@property (retain, nonatomic) NSString *	profileImage;
@property (retain, nonatomic) NSData   *	profileImageData;
@property (retain, nonatomic) NSString *	screenName;
@property (retain, nonatomic) NSString *	settings;
@property (retain, nonatomic) NSString *	views;

-(id)init;
-(NSString*)description;
-(void)dealloc;

@end
