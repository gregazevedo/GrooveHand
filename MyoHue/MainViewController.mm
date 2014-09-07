//
//  MainViewController.m
//  MyoLights
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Dolo. All rights reserved.
//

#import "MainViewController.h"
#import "MainViewController+HueDelegate.h"
#import "MyoMusicPlayer.h"

@interface MainViewController ()

@property (weak) IBOutlet NSButton *lightsButton;
@property (weak) IBOutlet NSButton *musicButton;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) Myo *myMyo;
@property (nonatomic) MyoMusicPlayer *player;

@end


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.index = 0;
        self.player = [MyoMusicPlayer new];
        self.isPartyMode = false;
    }
    return self;
}

-(void)awakeFromNib {
    
    [super awakeFromNib];
    [self retrieveInitialHueInfo];
    [self createColors];
    self.myMyo = [[Myo alloc] initWithApplicationIdentifier:@"com.example.myoobjc"];
    BOOL found = false;
    while (!found) {
        found = [self.myMyo connectMyoWaiting:10000];
    }
    self.myMyo.delegate = self;
    self.myMyo.updateTime = 1000;
}

- (IBAction)lightsButtonPushed:(id)sender {
    
    if([self.musicButton state] == 1){
        [self.musicButton setState:0];
    }
    if([self.lightsButton state] == 1){
        [self.myMyo startUpdate];
    }else{
        [self.myMyo stopUpdate];
    }
}

- (IBAction)musicButtonPushed:(id)sender {
    if([self.lightsButton state] == 1){
        [self.lightsButton setState:0];
    }
    
    if([self.musicButton state] == 1) {
        NSLog(@"Pressed music");
    }
}



@end
