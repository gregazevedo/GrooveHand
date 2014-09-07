//
//  MainViewController+HueDelegate.h
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController (HueDelegate)

-(void)retrieveInitialHueInfo;
-(void)updateHueWithMessageBody:(NSString *)messageBody;
-(void)createColors;

@end
