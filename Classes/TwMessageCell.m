//
//  TwMessageCell.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 12/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "TwMessageCell.h"
#import "util.h"

#define IMAGE_SIDE              48
#define BORDER_WIDTH            5

#define TEXT_OFFSET_X           (BORDER_WIDTH * 2 + IMAGE_SIDE)
#define TEXT_OFFSET_Y           (BORDER_WIDTH * 2 + LABEL_HEIGHT)
#define TEXT_WIDTH              (320 - TEXT_OFFSET_X - BORDER_WIDTH) - YFROG_IMAGE_WIDTH - BORDER_WIDTH
#define TEXT_HEIGHT             (ROW_HEIGHT - TEXT_OFFSET_Y - BORDER_WIDTH)

#define LABEL_HEIGHT            20
#define LABEL_WIDTH             130

#define YFROG_IMAGE_WIDTH       48

#define YFROG_IMAGE_X           TEXT_OFFSET_X
#define YFROG_IMAGE_Y           TEXT_OFFSET_Y + TEXT_HEIGHT
#define ROW_HEIGHT              70

@implementation TwMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
    {
        CGRect rect;
        
        rect = CGRectMake(BORDER_WIDTH, (ROW_HEIGHT - IMAGE_SIDE) / 2.0, IMAGE_SIDE, IMAGE_SIDE);
        _avatarImage = [[CustomImageView alloc] initWithFrame:rect];
        
		rect = CGRectMake(TEXT_OFFSET_X, BORDER_WIDTH, LABEL_WIDTH, LABEL_HEIGHT);
        _screennameLabel = [[UILabel alloc] initWithFrame:rect];
		_screennameLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
		_screennameLabel.highlightedTextColor = [UIColor whiteColor];
		_screennameLabel.opaque = NO;
		_screennameLabel.backgroundColor = [UIColor clearColor];
		
		rect = CGRectMake(TEXT_OFFSET_X + LABEL_WIDTH, BORDER_WIDTH, LABEL_WIDTH, LABEL_HEIGHT);
		_dateLabel = [[UILabel alloc] initWithFrame:rect];
		_dateLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		_dateLabel.textAlignment = UITextAlignmentRight;
		_dateLabel.highlightedTextColor = [UIColor whiteColor];
		_dateLabel.textColor = [UIColor lightGrayColor];
		_dateLabel.opaque = NO;
		_dateLabel.backgroundColor = [UIColor clearColor];
        
		rect = CGRectMake(TEXT_OFFSET_X, TEXT_OFFSET_Y, TEXT_WIDTH, TEXT_HEIGHT);
		_messageLabel = [[UILabel alloc] initWithFrame:rect];
		_messageLabel.lineBreakMode = UILineBreakModeWordWrap;
		_messageLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		_messageLabel.highlightedTextColor = [UIColor whiteColor];
		_messageLabel.numberOfLines = 0;
		_messageLabel.opaque = NO;
		_messageLabel.backgroundColor = [UIColor clearColor];
		
        rect = CGRectMake(300, TEXT_OFFSET_Y, 16, 16);
        _favoriteImage = [[UIImageView alloc] initWithFrame:rect];
        
        rect = CGRectMake(0, 0, 320, 48);
        _imageGrid = [[TwImageGridView alloc] initWithFrame:rect];
        
        [self.contentView addSubview:_avatarImage];
        [self.contentView addSubview:_screennameLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_messageLabel];
        [self.contentView addSubview:_favoriteImage];
        [self.contentView addSubview:_imageGrid];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc 
{
    [_avatarImage release];
    [_screennameLabel release];
    [_dateLabel release];
    [_messageLabel release];
    [_favoriteImage release];
    [_imageGrid release];
    [super dealloc];
}

- (void)setTwitterMessageObject:(TwitterMessageObject*)object
{
    if (object)
    {
        CGRect cellFrame = [self frame];

        [_screennameLabel setText:object.screenname];
        
        [_messageLabel setText:object.message];
        [_messageLabel setFrame:CGRectMake(TEXT_OFFSET_X, TEXT_OFFSET_Y, TEXT_WIDTH + YFROG_IMAGE_WIDTH - 10, TEXT_HEIGHT)];
        [_messageLabel sizeToFit];

        [_dateLabel setText:object.creationFormattedDate];
        
        [_avatarImage setImage:object.avatar];
        
        UIImage *favoriteImage = nil;
        if (object.isFavorite)
        {
            //YFLog(@"FAVORITE_IMAGE");
            favoriteImage = [UIImage imageNamed:@"statusfav.png"];
        }
        [_favoriteImage setImage:favoriteImage];
        
        float row_max_y = _messageLabel.frame.origin.y + _messageLabel.frame.size.height + BORDER_WIDTH;
        
        cellFrame.size.height = max(row_max_y, ROW_HEIGHT);
        
        BOOL hasThumbnails = NO;
        if (object.yfrogLinks && [object.yfrogLinks count] > 0)
            hasThumbnails = YES;
        
        _imageGrid.hidden = !hasThumbnails;
        if (hasThumbnails)
        {
            float max_grid_width = cellFrame.size.width - _avatarImage.frame.size.width + BORDER_WIDTH * 2;
            
            TwImageGridViewProxy *proxy = [[TwImageGridViewProxy alloc] init];
            proxy.imageLinks = object.yfrogLinks;
            
            CGSize grid_size = [proxy calculateSize:max_grid_width];
            [proxy release];
            
            CGRect grid_frame = CGRectMake(_avatarImage.frame.size.width + BORDER_WIDTH * 2, row_max_y, grid_size.width, grid_size.height);
            
            _imageGrid.frame = grid_frame;
            
            cellFrame.size.height = grid_frame.origin.y + grid_frame.size.height + BORDER_WIDTH;
            
            if (object.yfrogThumbnails == nil)
                [_imageGrid startIndicator];
            else
                _imageGrid.images = object.yfrogThumbnails;
        }
        
        [self setFrame:cellFrame];
    }
}

@end
