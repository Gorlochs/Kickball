//
//  FriendsListTableCellv2.m
//  Kickball
//
//  Created by Shawn Bernard on 3/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendsListTableCellv2.h"


@implementation FriendsListTableCellv2

@synthesize userIcon, _cancelTouches;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        CGRect frame = CGRectMake(8, 8, 36, 36);
        userIcon = [[TTImageView alloc] initWithFrame:frame];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:userIcon];
    }
    return self;
}

-(void) tapNHoldFired {
    self->_cancelTouches = YES;
    // DO WHATEVER YOU LIKE HERE!!!
    UIAlertView *apiAlert = [[UIAlertView alloc] initWithTitle:@"touch test" message:@"normally this would check you in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [apiAlert show];
    [apiAlert release];
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
    [userIcon release];
    [super dealloc];
}


@end
