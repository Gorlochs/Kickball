//
//  KBInstacheckinTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 4/1/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBInstacheckinTableCell.h"
#import "Utilities.h"

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
    NSDictionary *messageInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[Utilities safeString:self.venueId], nil] forKeys:[NSArray arrayWithObjects:@"venueIdOfCell", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchAndHoldCheckin"
                                                        object:nil
                                                      userInfo:messageInfo];
}
-(void) startSpinner {
	spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake(touchLocation.x-64, touchLocation.y-64, 128, 128)];

	[spinnerView setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"qc01.png"],
									 [UIImage imageNamed:@"qc02.png"],
									 [UIImage imageNamed:@"qc03.png"],
									 [UIImage imageNamed:@"qc04.png"],
									 [UIImage imageNamed:@"qc05.png"],
									 [UIImage imageNamed:@"qc06.png"],
									 [UIImage imageNamed:@"qc07.png"],
									 [UIImage imageNamed:@"qc08.png"],
									 [UIImage imageNamed:@"qc09.png"],
									 [UIImage imageNamed:@"qc10.png"],
									 [UIImage imageNamed:@"qc11.png"],
									 [UIImage imageNamed:@"qc12.png"],
									 [UIImage imageNamed:@"qc13.png"],
									 [UIImage imageNamed:@"qc14.png"],
									 [UIImage imageNamed:@"qc15.png"],
									 [UIImage imageNamed:@"qc16.png"],
									 [UIImage imageNamed:@"qc17.png"],
									 [UIImage imageNamed:@"qc18.png"],
									 [UIImage imageNamed:@"qc19.png"],
									 [UIImage imageNamed:@"qc20.png"],nil]];
	[spinnerView setAnimationDuration:0.75f];
	[spinnerView setAnimationRepeatCount:1];
	[self.superview addSubview:spinnerView];
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
    self->_cancelTouches = NO;
    [super touchesBegan:touches withEvent:event];
    [self performSelector:@selector(tapNHoldFired) withObject:nil afterDelay:1.0];
	[self performSelector:@selector(startSpinner) withObject:nil afterDelay:.25];
	touchLocation = [[touches anyObject] locationInView:self.superview];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelTapNHold];
    if (self->_cancelTouches)
        return;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self cancelTapNHold];
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
