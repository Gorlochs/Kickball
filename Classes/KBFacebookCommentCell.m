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
@synthesize userIcon, commentText, fbPictureUrl;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
		iconBgImage.frame = CGRectMake(8, 10, 38, 38);
		[self addSubview:iconBgImage];
		
        userIcon = [[TTImageView alloc] initWithFrame:CGRectMake(10, 12, 34, 34)];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
		
		commentText = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
		commentText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		commentText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
		commentText.backgroundColor = [UIColor clearColor];
		[self addSubview:commentText];
		
		topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        [self addSubview:topLineImage];
        
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        [self addSubview:bottomLineImage];
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
	topLineImage.frame = CGRectMake(0, 0, contentRect.size.width, 1);
	bottomLineImage.frame = CGRectMake(0, contentRect.size.height - 1, contentRect.size.width, 1);
	
	[userIcon setFrame:CGRectMake(10, contentRect.origin.y+12, 34, 34)];//CGPointMake(27, contentRect.size.height/2)];
	[iconBgImage setFrame:CGRectMake(8, contentRect.origin.y+10, 38, 38)];//CGPointMake(27, contentRect.size.height/2)];
}

-(void)setFbPictureUrl:(NSString *)_url{
	//avoid reloading the image if it;s the same one already in use	
	if ([fbPictureUrl isEqualToString:_url]) {
		return;
	}
	[fbPictureUrl release];
	fbPictureUrl = nil;
	fbPictureUrl = [_url copy];
	NSString *cachedUrl = [[FacebookProxy instance].pictureUrls objectForKey:fbPictureUrl];
	if (cachedUrl!=nil) {
		[userIcon setUrlPath:cachedUrl];
	}else {
		[NSThread detachNewThreadSelector:@selector(loadPicUrl) toTarget:self withObject:nil];
	}
	
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
	[topLineImage release];
	[bottomLineImage release];
	[iconBgImage release];
	[userIcon release];
	[commentText release];
	[fbPictureUrl release];
    [super dealloc];
}


@end
