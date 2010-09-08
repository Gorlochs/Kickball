//
//  KBFacebookCommentCell.m
//  Kickball
//
//  Created by scott bates on 6/18/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookCommentCell.h"
#import "FacebookProxy.h"
#import "GraphObject.h"
#import "GraphAPI.h"

@implementation KBFacebookCommentCell
@synthesize commentText, fbPictureUrl;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
	
		commentText = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
		commentText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		commentText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
		commentText.backgroundColor = [UIColor clearColor];
		[self addSubview:commentText];
		
		fbPictureUrl = nil;
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	//userName.frame = CGRectMake(58, contentRect.origin.y+10, 150, 20);
	commentText.frame = CGRectMake(contentRect.origin.x+58, contentRect.origin.y+10, 250, commentText.frame.size.height);
	//CGFloat textHeight = commentText.frame.size.height;
	
	//tweetText.center = CGPointMake(tweetText.center.x,(tweetText.frame.size.height/2)+32);
	
	[userIcon setFrame:CGRectMake(8, contentRect.origin.y+12, 38, 38)];//CGPointMake(27, contentRect.size.height/2)];
	[iconBgImage setFrame:CGRectMake(8, contentRect.origin.y+12, 38, 38)];//CGPointMake(27, contentRect.size.height/2)];
}

-(void)setFbPictureUrl:(NSString *)_url{
	//avoid reloading the image if it;s the same one already in use	
	if ([fbPictureUrl isEqualToString:_url]) {
	//	return;
	}
	[fbPictureUrl release];
	fbPictureUrl = nil;
	if (_url != nil) {
		if ([_url isKindOfClass:[NSNull class]]) {
			DLog(@"Fish Bug");
		}else {
			NSString *forceUTF = [[NSString alloc] initWithUTF8String:[_url UTF8String]];
			fbPictureUrl = [forceUTF stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			[forceUTF release];
			[fbPictureUrl retain];
			DLog(@"fbPictureUrl:: %@",fbPictureUrl);
		}

		
		
	}
		//NSString *cachedUrl = [[FacebookProxy instance].pictureUrls objectForKey:fbPictureUrl];
	//if (cachedUrl!=nil) {
		//[userIcon setUrlPath:fbPictureUrl];
	[userIcon performSelectorOnMainThread:@selector(setUrlPath:) withObject:fbPictureUrl waitUntilDone:YES];

	//}else {
	//	[NSThread detachNewThreadSelector:@selector(loadPicUrl) toTarget:self withObject:nil];
	//}
	
}

-(void)loadPicUrl{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary* args = [NSDictionary dictionaryWithObject:@"picture" forKey:@"fields"];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	GraphObject *fbItem = [graph getObject:fbPictureUrl withArgs:args];
	//userIcon.urlPath = [fbItem propertyWithKey:@"picture"];
	NSString *staticUrl = [fbItem propertyWithKey:@"picture"];
	if (staticUrl!=nil) {
		[[FacebookProxy instance].pictureUrls setObject:staticUrl forKey:fbPictureUrl];
		[userIcon performSelectorOnMainThread:@selector(setUrlPath:) withObject:staticUrl waitUntilDone:YES];
		
	}
	[graph release];
	[pool release];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	
	[commentText release];
	[fbPictureUrl release];
    [super dealloc];
}


@end
