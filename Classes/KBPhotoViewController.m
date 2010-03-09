//
//  KBPhotoViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBPhotoViewController.h"
#import "MockPhotoSource.h"


@implementation KBPhotoViewController

@synthesize startIndex;

- (void)loadView {
    [super loadView];
    
    _flagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flag_off.png"] 
                                                   style:UIBarButtonItemStylePlain
                                                  target:self 
                                                  action:@selector(flagAction)];
    
    
    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    _toolbar.items = [NSArray arrayWithObjects:
                      space, _previousButton, space, _flagButton, space, _nextButton, space, nil];
    
}


- (void)flagAction {
    NSLog(@"photo index: %d", _centerPhotoIndex);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Would you like to flag this photo as inappropriate?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"INAPPROPRIATE!!!!");
    }
}

@end
