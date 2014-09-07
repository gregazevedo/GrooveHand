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
}

- (IBAction)lightsButtonPushed:(id)sender {
    
    if([self.musicButton state] == 1){
        [self.musicButton setState:0];
    }
    if([self.lightsButton state] == 1){
        [self.myMyo startUpdate];
    }else{
        [self.timer invalidate];
    }
}

- (IBAction)musicButtonPushed:(id)sender {
    if([self.lightsButton state] == 1){
        [self.lightsButton setState:0];
        [self.timer invalidate];
    }
    
    if([self.musicButton state] == 1) {
        NSLog(@"Pressed music");
    }
}



@end
