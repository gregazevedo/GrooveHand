//
//  MYHAppDelegate.m
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MYHAppDelegate.h"
#include "MainViewController.h"

@interface MYHAppDelegate()

@property (nonatomic) IBOutlet MainViewController *mainVC;

@end

@implementation MYHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    [self.window.contentView addSubview:self.mainVC.view];
    self.mainVC.view.frame = ((NSView*)self.window.contentView).bounds;
}

@end
