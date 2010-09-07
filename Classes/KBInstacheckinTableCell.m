//
//  KBInstacheckinTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 4/1/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBInstacheckinTableCell.h"
#import "Utilities.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation KBInstacheckinTableCell

@synthesize _cancelTouches, venueId;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
//        UIView *v = [[[UIView alloc] init] autorelease];
//        v.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:0.0 blue:25.0/255.0 alpha:1.0];
//        self.selectedBackgroundView = v;
        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		spinnerView = nil;
    }
    return self;
}

-(void) tapNHoldFired {
    self->_cancelTouches = YES;
	[self stopSpinner];
    // DO WHATEVER YOU LIKE HERE!!!
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	NSDictionary *messageInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[Utilities safeString:self.venueId], nil] forKeys:[NSArray arrayWithObjects:@"venueIdOfCell", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchAndHoldCheckin"
                                                        object:nil
                                                      userInfo:messageInfo];
}
-(void) startSpinner {
	spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake(touchLocation.x-64, touchLocation.y-64, 128, 128)];

	[spinnerView setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"quick01.png"],
									 [UIImage imageNamed:@"quick02.png"],
									 [UIImage imageNamed:@"quick03.png"],
									 [UIImage imageNamed:@"quick04.png"],
									 [UIImage imageNamed:@"quick05.png"],
									 [UIImage imageNamed:@"quick06.png"],
									 [UIImage imageNamed:@"quick07.png"],
									 [UIImage imageNamed:@"quick08.png"],
									 [UIImage imageNamed:@"quick09.png"],
									 [UIImage imageNamed:@"quick10.png"],
									 [UIImage imageNamed:@"quick11.png"],
									 [UIImage imageNamed:@"quick12.png"],
									 [UIImage imageNamed:@"quick13.png"],
									 [UIImage imageNamed:@"quick14.png"],
									 [UIImage imageNamed:@"quick15.png"],
									 [UIImage imageNamed:@"quick16.png"],
									 [UIImage imageNamed:@"quick17.png"],
									 [UIImage imageNamed:@"quick18.png"],
									 [UIImage imageNamed:@"quick19.png"],
									 [UIImage imageNamed:@"quick20.png"],
									 [UIImage imageNamed:@"quick21.png"],
									 [UIImage imageNamed:@"quick22.png"],
									 [UIImage imageNamed:@"quick23.png"],
									 [UIImage imageNamed:@"quick24.png"],nil]];
	[spinnerView setAnimationDuration:0.75f];
	[spinnerView setAnimationRepeatCount:1];
	[self.superview.superview addSubview:spinnerView];
	[spinnerView startAnimating];
}

-(void) stopSpinner {
	[spinnerView removeFromSuperview];
	[spinnerView stopAnimating];
	[spinnerView release];
	spinnerView = nil;
}
-(void) cancelTapNHold {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tapNHoldFired) object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSpinner) object:nil];
	[self stopSpinner];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([[Utilities sharedInstance] isInstacheckinOn]) {
		self->_cancelTouches = NO;
		[super touchesBegan:touches withEvent:event];
		[self performSelector:@selector(tapNHoldFired) withObject:nil afterDelay:0.9];
		[self performSelector:@selector(startSpinner) withObject:nil afterDelay:.25];
		touchLocation = [[touches anyObject] locationInView:self.superview.superview];
	} else {
		[super touchesBegan:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelTapNHold];
    if (self->_cancelTouches)
        return;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint movedTouch = [[touches anyObject] locationInView:self.superview];
	float movedDistX = movedTouch.x - touchLocation.x;
	if (movedDistX < 0) movedDistX = -movedDistX;
	float movedDistY = movedTouch.y - touchLocation.y;
	if (movedDistY < 0) movedDistY = -movedDistY;
	if (movedDistX + movedDistY > 30) [self cancelTapNHold]; //cancel if they move their finger away, but not if their finger shakes
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelTapNHold];
    [super touchesCancelled:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
