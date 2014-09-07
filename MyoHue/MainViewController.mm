//
//  MainViewController.m
//  MyoLights
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Dolo. All rights reserved.
//

#import "MainViewController.h"
#import "MyoMusicPlayer.h"
#import "MYHHueConnection.h"

@interface MainViewController ()

@property (weak) IBOutlet NSButton *lightsButton;
@property (weak) IBOutlet NSButton *musicButton;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) Myo *myMyo;

@end


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.player = [MyoMusicPlayer new];
        self.lights = [MYHHueConnection new];
    }
    return self;
}

-(void)awakeFromNib {
    
    [super awakeFromNib];
    [self.lights retrieveInitialHueInfo];
    [self.lights createColors];
    self.myMyo = [[Myo alloc] initWithApplicationIdentifier:@"com.example.myoobjc"];
    BOOL found = false;
    while (!found) {
        found = [self.myMyo connectMyoWaiting:10000];
    }
    self.myMyo.delegate = self;
    self.myMyo.updateTime = 1000;
    self.mode = MYHModeLights;
}

- (IBAction)lightsButtonPushed:(id)sender
{
    self.mode = MYHModeLights;
}

- (IBAction)musicButtonPushed:(id)sender
{
    self.mode = MYHModeMusic;
}

-(void)setMode:(MYHMode)mode
{
    switch (mode) {
        case MYHModeLights:
//            [self.lightsButton setState:NSOnState];
            [self.lightsButton highlight:YES];
//            [self.musicButton setState:NSOffState];
            [self.musicButton highlight:NO];
            break;
        case MYHModeMusic:
//            [self.musicButton setState:NSOnState];
            [self.musicButton highlight:YES];

//            [self.lightsButton setState:NSOffState];
            [self.lightsButton highlight:NO];
            break;
        default:
            break;
    }
    [self.myMyo startUpdate];
}

@end
