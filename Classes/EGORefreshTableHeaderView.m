//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "KickballAppDelegate.h"

#define TEXT_COLOR	 [UIColor colorWithRed:117.0/255.0 green:0.0/255.0 blue:14.0/255.0 alpha:1.0]
#define BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]


@implementation EGORefreshTableHeaderView

@synthesize state=_state;
@synthesize bottomBorderThickness;
@synthesize bottomBorderColor;

// Sets up the frame following the recipe in the samples except it doesn't *overlap* the partner view,
// ensuring that if you choose to draw a bottom border (by setting bottomBorderThickness > 0.0) then
// you'll get a proper border, not a partially obscured one.
- (id)initWithFrameRelativeToFrame:(CGRect)originalFrame {
	CGRect relativeFrame = CGRectMake(0.0f, 0.0f - (originalFrame.size.height + 1.0f), originalFrame.size.width, originalFrame.size.height);
	return [self initWithFrame:relativeFrame];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
		arrowsAndText = [[UIImageView alloc] initWithFrame:CGRectMake(10, frame.size.height - 41.0f, 301, 20)];
		if (appDelegate.navControllerType == KBNavControllerTypeFoursquare) {
			self.backgroundColor = [UIColor colorWithRed:176.0/255.0 green:36.0/255.0 blue:44.0/255.0 alpha:1.0];
			[arrowsAndText setImage:[UIImage imageNamed:@"pull4SQ01.png"]];
		} else if (appDelegate.navControllerType == KBNavControllerTypeTwitter) {
			self.backgroundColor = [UIColor colorWithRed:43.0/255.0 green:190.0/255.0 blue:251.0/255.0 alpha:1.0];
			[arrowsAndText setImage:[UIImage imageNamed:@"pullTW01.png"]];
		} else if (appDelegate.navControllerType == KBNavControllerTypeFacebook) {
			self.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:127.0/255.0 blue:220.0/255.0 alpha:1.0];
			[arrowsAndText setImage:[UIImage imageNamed:@"pullFB01.png"]];
        }
		[self addSubview:arrowsAndText];
//		lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
//		lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
//		lastUpdatedLabel.textColor = TEXT_COLOR;
//		lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
//		lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
//		lastUpdatedLabel.backgroundColor = [UIColor clearColor];
//		lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
//		[self addSubview:lastUpdatedLabel];
//		[lastUpdatedLabel release];

//		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"EGORefreshTableView_LastRefresh"]) {
//			lastUpdatedLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"EGORefreshTableView_LastRefresh"];
//		} else {
//			[self setCurrentDate];
//		}
		
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 41.0f, self.frame.size.width, 20.0f)];
		statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		statusLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		if (appDelegate.navControllerType == KBNavControllerTypeFoursquare) {
			statusLabel.textColor = TEXT_COLOR;
		} else if (appDelegate.navControllerType == KBNavControllerTypeTwitter) {
			statusLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:118.0/255.0 blue:164.0/255.0 alpha:1.0];
		} else if (appDelegate.navControllerType == KBNavControllerTypeFacebook) {
			statusLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:72.0/255.0 blue:140.0/255.0 alpha:1.0];
        }
		//		statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		//		statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textAlignment = UITextAlignmentCenter;
		[self setState:EGOOPullRefreshNormal];
		[self addSubview:statusLabel];
		[statusLabel release];
		
		/*
		
		arrowImage = [[CALayer alloc] init];
		arrowImage.frame = CGRectMake(10.0f, frame.size.height - 35.0f, 19.0f, 21.0f);
		arrowImage.contentsGravity = kCAGravityResizeAspect;
		arrowImage.contents = (id)[UIImage imageNamed:@"pullRefreshArrow.png"].CGImage;
		[[self layer] addSublayer:arrowImage];
		[arrowImage release];
		
		arrowImage2 = [[CALayer alloc] init];
		arrowImage2.frame = CGRectMake(290.0f, frame.size.height - 35.0f, 19.0f, 21.0f);
		arrowImage2.contentsGravity = kCAGravityResizeAspect;
		arrowImage2.contents = (id)[UIImage imageNamed:@"pullRefreshArrow.png"].CGImage;
		[[self layer] addSublayer:arrowImage2];
		[arrowImage2 release];
		*/
		
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
		
    }
    return self;
}

// Will only draw a bottom border if you've set bottomBorderThickness to be > 0.0
// and makes sure that the stroke is correctly centered so you get a border as thick
// as you've asked for.
- (void)drawRect:(CGRect)rect{
	if ([self bottomBorderThickness] == 0.0f) return;
	CGFloat strokeOffset = [self bottomBorderThickness] / 2.0f;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawPath(context,  kCGPathFillStroke);
	UIColor *strokeColor = ([self bottomBorderColor]) ? [self bottomBorderColor] : BORDER_COLOR;
	[strokeColor setStroke];
	CGContextSetLineWidth(context, [self bottomBorderThickness]);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, self.bounds.size.height - strokeOffset);
	CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - strokeOffset);
	CGContextStrokePath(context);
}

//- (void)setLastRefreshDate:(NSDate*)date
//{
//  if (!date) {
//    [lastUpdatedLabel setText:NSLocalizedString(@"Never Updated", @"No Last Update Date text")];
//    return;
//  }
//  
//	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//	[formatter setAMSymbol:@"AM"];
//	[formatter setPMSymbol:@"PM"];
//	[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
//	lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
//	[formatter release];
//}
//
//- (void)setCurrentDate {
//	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//	[formatter setAMSymbol:@"AM"];
//	[formatter setPMSymbol:@"PM"];
//	[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
//	lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:[NSDate date]]];
//	[[NSUserDefaults standardUserDefaults] setObject:lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	[formatter release];
//}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			//statusLabel.text = @"";
			statusLabel.text = @"Release to refresh...";
			
			[CATransaction begin];
			[CATransaction setAnimationDuration:.18];
			if (appDelegate.navControllerType == KBNavControllerTypeFoursquare) {
				[arrowsAndText setImage:[UIImage imageNamed:@"pull4SQ02.png"]];
			} else if (appDelegate.navControllerType == KBNavControllerTypeTwitter) {
				[arrowsAndText setImage:[UIImage imageNamed:@"pullTW02.png"]];
			} else if (appDelegate.navControllerType == KBNavControllerTypeFacebook) {
				[arrowsAndText setImage:[UIImage imageNamed:@"pullFB02.png"]];
			}
			//arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			//arrowImage2.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:.18];
				if (appDelegate.navControllerType == KBNavControllerTypeFoursquare) {
					[arrowsAndText setImage:[UIImage imageNamed:@"pull4SQ01.png"]];
				} else if (appDelegate.navControllerType == KBNavControllerTypeTwitter) {
					[arrowsAndText setImage:[UIImage imageNamed:@"pullTW01.png"]];
				} else if (appDelegate.navControllerType == KBNavControllerTypeFacebook) {
					[arrowsAndText setImage:[UIImage imageNamed:@"pullFB01.png"]];
				}
				//arrowImage.transform = CATransform3DIdentity;
				//arrowImage2.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			//statusLabel.text = @"";
			statusLabel.text = @"Pull down to refresh...";
			[activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			if (appDelegate.navControllerType == KBNavControllerTypeFoursquare) {
				[arrowsAndText setImage:[UIImage imageNamed:@"pull4SQ01.png"]];
			} else if (appDelegate.navControllerType == KBNavControllerTypeTwitter) {
				[arrowsAndText setImage:[UIImage imageNamed:@"pullTW01.png"]];
			} else if (appDelegate.navControllerType == KBNavControllerTypeFacebook) {
				[arrowsAndText setImage:[UIImage imageNamed:@"pullFB01.png"]];
			}
			arrowsAndText.hidden = NO;
			//arrowImage.hidden = NO;
			//arrowImage.transform = CATransform3DIdentity;
			//arrowImage2.hidden = NO;
			//arrowImage2.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshLoading:
			
			statusLabel.text = @"Loading...";
			[activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowsAndText.hidden = YES;
			//arrowImage.hidden = YES;
			//arrowImage2.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)dealloc {
	[bottomBorderColor release], bottomBorderColor = nil;
	[arrowsAndText release];
	[activityView release];
	activityView = nil;
	//statusLabel = nil;
	//arrowImage = nil;
	//arrowImage2 = nil;
	lastUpdatedLabel = nil;
    [super dealloc];
}


@end
