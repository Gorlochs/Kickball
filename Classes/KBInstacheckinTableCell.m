//
//  KBInstacheckinTableCell.m
//  Kickball
//
//  Created by Shawn Bernard on 4/1/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBInstacheckinTableCell.h"


@implementation KBInstacheckinTableCell

@synthesize _cancelTouches, venueId;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        UIView *v = [[[UIView alloc] init] autorelease];
        v.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:0.0 blue:25.0/255.0 alpha:1.0];
        self.selectedBackgroundView = v;
        
        // FIXME: change selected font color
    }
    return self;
}

-(void) tapNHoldFired {
    self->_cancelTouches = YES;
    // DO WHATEVER YOU LIKE HERE!!!
    NSDictionary *messageInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.venueId, nil] forKeys:[NSArray arrayWithObjects:@"venueIdOfCell", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchAndHoldCheckin"
                                                        object:nil
                                                      userInfo:messageInfo];
}

-(void) cancelTapNHold {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tapNHoldFired) object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self->_cancelTouches = NO;
    [super touchesBegan:touches withEvent:event];
    [self performSelector:@selector(tapNHoldFired) withObject:nil afterDelay:.7];
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
