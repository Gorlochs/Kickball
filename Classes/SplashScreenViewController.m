//
//  SplashScreenViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 2/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "SplashScreenViewController.h"


@implementation SplashScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    NSLog(@"**************** nib splash screen displaying *****************");
    [self setupSplashAnimation];
    [splashView startAnimating];
    return self;
}

- (void)viewDidLoad {
    NSLog(@"**************** splash screen displaying *****************");
    [self setupSplashAnimation];
    [splashView startAnimating];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"**************** will appear splash screen displaying *****************");
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"**************** memory warning *****************");
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) setupSplashAnimation {
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 1; i < 40; i++) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"kickballLoading%02d.png", i]]];
        //        [images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"kickballLoading%02d", i] ofType:@"png"]]];
    }
    
    splashView.animationImages = [[NSArray alloc] initWithArray:images];
    [images release];
    splashView.animationDuration = 2.0;
    splashView.animationRepeatCount = 1;
}

- (void)dealloc {
    [super dealloc];
}


@end
