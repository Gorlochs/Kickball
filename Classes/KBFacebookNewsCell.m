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

@implementation KBFacebookNewsCell

@synthesize userIcon;
@synthesize userName;
@synthesize tweetText;
@synthesize dateLabel;
@synthesize fbProfilePicUrl, fbPictureUrl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.contentView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        userIcon = [[TTImageView alloc] initWithFrame:CGRectMake(10, 18, 34, 34)];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
        
		
        iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
		iconBgImage.frame = CGRectMake(8, 16, 38, 38);
        [self addSubview:iconBgImage];
		iconButt = [UIButton buttonWithType:UIButtonTypeCustom];
		[iconButt setFrame:CGRectMake(8, 16, 38, 38)];
		[iconButt retain];
		[iconButt addTarget:self action:@selector(pushToProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:iconButt];
        
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
		
        topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        [self addSubview:topLineImage];
        
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        [self addSubview:bottomLineImage];
		fbProfilePicUrl = nil;
		fbPictureUrl = nil;
		pictureThumb1 = [[TTImageView alloc] initWithFrame:CGRectMake(60, 50, 34, 34)];
        pictureThumb1.backgroundColor = [UIColor clearColor];
        //pictureThumb1.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        pictureThumb1.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        pictureThumb1.contentMode = UIViewContentModeScaleAspectFit;		
		
		pictureActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		pictureActivityIndicator.frame = CGRectMake(60, 50, 20, 20);
		pictureActivityIndicator.center = pictureThumb1.center;
		pictureActivityIndicator.hidden = YES;
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
	topLineImage.frame = CGRectMake(0, 0, contentRect.size.width, 1);
	bottomLineImage.frame = CGRectMake(0, contentRect.size.height - 1, contentRect.size.width, 1);
	
	[iconButt setFrame:CGRectMake(8, contentRect.origin.y+10, 38, 38)];//CGPointMake(27, contentRect.size.height/2)];
	[userIcon setFrame:CGRectMake(10, contentRect.origin.y+12, 34, 34)];//CGPointMake(27, contentRect.size.height/2)];
	[iconBgImage setFrame:CGRectMake(8, contentRect.origin.y+10, 38, 38)];//CGPointMake(27, contentRect.size.height/2)];
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
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
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
	[userIcon setUrlPath:fbProfilePicUrl];
	

}

-(void)setFbPictureUrl:(NSString *)_url{
	//avoid reloading the image if it;s the same one already in use	
	if (_url == nil) {
		[pictureThumb1 removeFromSuperview];
		return;
	}else{
		if ([pictureThumb1 superview] !=self) {
			[self addSubview:pictureThumb1];
		}
	}
	
	pictureActivityIndicator.hidden = NO;
	[fbPictureUrl release];
	fbPictureUrl = nil;
	fbPictureUrl = [_url copy];
	[pictureThumb1 setUrlPath:fbPictureUrl];
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

- (void)dealloc {
	[fbProfilePicUrl release];
    [userIcon release];
    [userName release];
	[iconButt retain];
    [tweetText release];
    [dateLabel release];
    [commentBG release];
	[commentNumber release];
    [topLineImage release];
    [bottomLineImage release];
    [iconBgImage release];
    [super dealloc];
}


@end
