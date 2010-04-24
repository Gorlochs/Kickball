//
//  PlacesListTableViewCellv2.m
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlacesListTableViewCellv2.h"


@implementation PlacesListTableViewCellv2

@synthesize categoryIcon;
@synthesize venueName;
@synthesize venueAddress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        CGRect frame = CGRectMake(6, 6, 32, 32);
        categoryIcon = [[TTImageView alloc] initWithFrame:frame];
        categoryIcon.backgroundColor = [UIColor clearColor];
        categoryIcon.defaultImage = [UIImage imageNamed:@"blank.png"];
        categoryIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        [self addSubview:categoryIcon];
        
        venueName = [[UILabel alloc] initWithFrame:CGRectMake(46, 5, 250, 20)];
        venueName.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        venueName.font = [UIFont boldSystemFontOfSize:14.0];
        venueName.backgroundColor = [UIColor clearColor];
        venueName.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueName.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:venueName];
        
        venueAddress = [[UILabel alloc] initWithFrame:CGRectMake(46, 20, 250, 20)];
        venueAddress.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        venueAddress.font = [UIFont systemFontOfSize:12.0];
        venueAddress.backgroundColor = [UIColor clearColor];
        venueAddress.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        venueAddress.shadowOffset = CGSizeMake(1.0, 1.0);
        [self addSubview:venueAddress];
        
        topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        topLineImage.frame = CGRectMake(0, 0, self.frame.size.width, 1);
        [self addSubview:topLineImage];
        
        // TODO: the origin.y should probably not be hard coded
        bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        bottomLineImage.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
        [self addSubview:bottomLineImage];
    }
    return self;
}

- (void) adjustLabelWidth:(float)newWidth {
    CGSize newSize = CGSizeMake(newWidth, 20);
    
    CGRect frame = venueName.frame;
    frame.size = newSize;
    venueName.frame = frame;
    
    CGRect frame2 = venueAddress.frame;
    frame2.size = newSize;
    venueAddress.frame = frame2;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
