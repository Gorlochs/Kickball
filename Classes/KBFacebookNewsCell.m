//
//  KBFacebookNewsCell.m
//  Kickball
//
//  Created by scott bates on 6/11/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookNewsCell.h"
#import "KickballAPI.h"
#import "FacebookProxy.h"
#import "GraphObject.h"
#import "GraphAPI.h"
#import "KBFacebookViewController.h"

@implementation KBFacebookNewsCell

@synthesize userName;
@synthesize tweetText;
@synthesize dateLabel;
@synthesize fbProfilePicUrl, fbPictureUrl, pictureAlbumId, pictureIndex;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        userName = [[UILabel alloc] init];
        userName.textColor = [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:219.0/255.0 alpha:1.0];
        userName.font = [UIFont boldSystemFontOfSize:16.0];
        userName.backgroundColor = [UIColor clearColor];
        userName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        userName.shadowOffset = CGSizeMake(1.0, 1.0);
        //[self addSubview:userName];
        
        dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		dateLabel.textAlignment = UITextAlignmentLeft;
        [self addSubview:dateLabel];
        
		tweetText = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
		tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		tweetText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
		tweetText.backgroundColor = [UIColor clearColor];
		[self addSubview:tweetText];
		
		/*
		 tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(66, 25, 250, 70)];
		 tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		 tweetText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
		 tweetText.backgroundColor = [UIColor clearColor];
		 tweetText.linksEnabled = YES;
		 tweetText.numberOfLines = 0;
		 //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		 //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
		 [self addSubview:tweetText];
		 */
		
		commentBG = [[UIImageView alloc] init];
		[commentBG setImage:[UIImage imageNamed:@"cmt-grey.png"]];
		[self addSubview:commentBG];
		
		commentNumber = [[UILabel alloc] init];
        commentNumber.textColor = [UIColor colorWithRed:25.0/255.0 green:144.0/255.0 blue:219.0/255.0 alpha:1.0];
        commentNumber.font = [UIFont boldSystemFontOfSize:12.0];
        commentNumber.backgroundColor = [UIColor clearColor];
        commentNumber.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        commentNumber.shadowOffset = CGSizeMake(1.0, 1.0);
		commentNumber.textAlignment = UITextAlignmentRight;
		[self addSubview:commentNumber];
		
		fbProfilePicUrl = nil;
		fbPictureUrl = nil;
		pictureThumb1 = [[TTImageView alloc] initWithFrame:CGRectMake(60, 50, 34, 34)];
        pictureThumb1.backgroundColor = [UIColor clearColor];
        pictureThumb1.defaultImage = [UIImage imageNamed:@"photoLoading.png"];
        pictureThumb1.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        pictureThumb1.contentMode = UIViewContentModeScaleAspectFit;
		pictureButt = [UIButton buttonWithType:UIButtonTypeCustom];
		[pictureButt setFrame:pictureThumb1.frame];
		[pictureButt retain];
		[pictureButt addTarget:self action:@selector(pressPhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
		[pictureButt setEnabled:NO];
				
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	//userName.frame = CGRectMake(58, contentRect.origin.y+10, 150, 20);
	tweetText.frame = CGRectMake(contentRect.origin.x+58, contentRect.origin.y+10, 250, tweetText.frame.size.height);
	//CGFloat textHeight = tweetText.frame.size.height;
	dateLabel.frame = CGRectMake(contentRect.origin.x+58, contentRect.size.height - 20, 200, 16);

	//tweetText.center = CGPointMake(tweetText.center.x,(tweetText.frame.size.height/2)+32);
	[iconButt setFrame:CGRectMake(8, contentRect.origin.y+10, 38, 38)];//CGPointMake(27, contentRect.size.height/2)];
	[userIcon setFrame:CGRectMake(4, contentRect.origin.y+12, 48, 48)];//CGPointMake(27, contentRect.size.height/2)];
	[iconBgImage setFrame:CGRectMake(4, contentRect.origin.y+12, 48, 48)];//CGPointMake(27, contentRect.size.height/2)];
	commentNumber.frame = CGRectMake(contentRect.origin.x+contentRect.size.width - 46, contentRect.size.height - 26, 40, 25);
	if (comments) {
		if (comments==1) {
			commentBG.frame = CGRectMake(contentRect.origin.x+contentRect.size.width - 40, contentRect.size.height - 26, 60, 25);
		}else if (comments < 10) {
			commentBG.frame = CGRectMake(contentRect.origin.x+contentRect.size.width - 40, contentRect.size.height - 26, 60, 24);
		}else if (comments < 100) {
			commentBG.frame = CGRectMake(contentRect.origin.x+contentRect.size.width - 50, contentRect.size.height - 26, 60, 24);
		}		else {
			commentBG.frame = CGRectMake(contentRect.origin.x+contentRect.size.width - 60, contentRect.size.height - 26, 60, 25);
		}

	}else {
		commentBG.frame = CGRectMake(contentRect.origin.x+contentRect.size.width - 25, contentRect.size.height - 26, 25, 25);
	}
	if (fbPictureUrl!=nil) {
		pictureThumb1.frame = CGRectMake(60, tweetText.frame.size.height+20, 130, 130);
		pictureButt.frame = pictureThumb1.frame;
	}

	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	if (selected) {
		//dateLabel.textColor = [UIColor whiteColor];
		dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        dateLabel.shadowOffset = CGSizeMake(0.0, 0.0);
	}else {
		//dateLabel.textColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
		dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	}
	
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (highlighted) {
		//dateLabel.textColor = [UIColor whiteColor];
		dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        dateLabel.shadowOffset = CGSizeMake(0.0, 0.0);
	}else {
		//dateLabel.textColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
		dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	}	
}



- (void) setDateLabelWithDate:(NSDate*)theDate {
    //DLog(@"label date: %@", theDate);
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:TWITTER_DISPLAY_DATE_FORMAT];
    dateLabel.text = [dateFormatter stringFromDate:theDate];
}

- (void) setDateLabelWithText:(NSString*)theDate {
    dateLabel.text = theDate;
	
}


-(void)setFbProfilePicUrl:(NSString *)_url{
	//avoid reloading the image if it;s the same one already in use	
	/*if ([fbProfilePicUrl isEqualToString:_url]) {
			return;
	}
	[fbProfilePicUrl release];
	fbProfilePicUrl = nil;
	fbProfilePicUrl = [_url copy];
	NSString *cachedUrl = [[FacebookProxy instance].pictureUrls objectForKey:fbProfilePicUrl];
	if (cachedUrl!=nil) {
		[userIcon setUrlPath:cachedUrl];
	}else {
		[NSThread detachNewThreadSelector:@selector(loadPicUrl) toTarget:self withObject:nil];
	}
	 */
	[fbProfilePicUrl release];
	fbProfilePicUrl = nil;
	fbProfilePicUrl = [_url copy];
	//userIcon.urlPath = _url;
	[userIcon performSelectorOnMainThread:@selector(setUrlPath:) withObject:fbProfilePicUrl waitUntilDone:NO];

	

}

-(void)setFbPictureUrl:(NSString *)_url{
	//avoid reloading the image if it;s the same one already in use	
	if (_url == nil) {
		[pictureThumb1 removeFromSuperview];
		[pictureButt removeFromSuperview];
		[pictureButt setEnabled:NO];
		return;
	}else{
		if ([pictureThumb1 superview] !=self) {
			[self addSubview:pictureThumb1];
			[self addSubview:pictureButt];
			[pictureButt setEnabled:YES];
		}
	}
	
	[fbPictureUrl release];
	fbPictureUrl = nil;
	fbPictureUrl = [_url copy];
	//pictureThumb1.urlPath = _url;
	[pictureThumb1 performSelectorOnMainThread:@selector(setUrlPath:) withObject:fbPictureUrl waitUntilDone:NO];


}

-(void)loadPicUrl{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary* args = [NSDictionary dictionaryWithObject:@"picture" forKey:@"fields"];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	GraphObject *fbItem = [graph getObject:fbProfilePicUrl withArgs:args];
	//userIcon.urlPath = [fbItem propertyWithKey:@"picture"];
	NSString *staticUrl = [fbItem propertyWithKey:@"picture"];
	if (staticUrl!=nil) {
		[[FacebookProxy instance].pictureUrls setObject:staticUrl forKey:fbProfilePicUrl];
		[userIcon performSelectorOnMainThread:@selector(setUrlPath:) withObject:staticUrl waitUntilDone:YES];

	}
	[graph release];
	[pool release];
}

- (void) pushToProfile{
	//UITableView *tv = (UITableView *) self.superview;
	//UITableViewController *vc = (UITableViewController *) tv.dataSource;
	//[(KBBaseTweetViewController*)vc viewUserProfile:userName.text];
}

-(void)setNumberOfComments:(int)howMany{
	comments = howMany;
	if (comments) {
		commentNumber.text = comments > 1 ? [NSString stringWithFormat:@"%i",comments] : [NSString stringWithFormat:@"%i",comments];
		commentBG.image = [UIImage imageNamed:@"cmt-blue.png"];
	}else{
		commentNumber.text = @" ";
		commentBG.image = [UIImage imageNamed:@"cmt-grey.png"];
	}
}

-(void)pressPhotoAlbum{
	UITableView *tv = (UITableView *) self.superview;
	UITableViewController *vc = (UITableViewController *) tv.dataSource;
	//[(KBFacebookViewController*)vc displayAlbum:pictureAlbumId];
	[(KBFacebookViewController*)vc displayAlbum:pictureAlbumId atIndex:pictureIndex];

}

- (void)dealloc {
	[pictureAlbumId release];
	[fbProfilePicUrl release];
    [userName release];
    [tweetText release];
    [dateLabel release];
    [commentBG release];
	[commentNumber release];
    [super dealloc];
}


@end
