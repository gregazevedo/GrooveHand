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

//@property (weak) IBOutlet  *lightsButton;
//@property (weak) IBOutlet NSButton *musicButton;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) Myo *myMyo;
@property (nonatomic) NSTextField *lightLabel;
@property (nonatomic) NSTextField *musicLabel;
@property (nonatomic) NSTextField *lockLabel;
@property (nonatomic) NSTextField *latestCommandLabel;

@end


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.player = [MyoMusicPlayer new];
        self.lights = [MYHHueConnection new];
        self.lightLabel = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(100, 0, 300, 30))];
        [self.lightLabel setTextColor:[NSColor whiteColor]];
        [self.lightLabel setAlignment:kCTTextAlignmentCenter];
        [self.lightLabel setFont:[NSFont systemFontOfSize:25]];
        [self.lightLabel setBackgroundColor:[NSColor clearColor]];
        [self.lightLabel setDrawsBackground:NO];
        [self.lightLabel setBezeled:NO];
        [self.lightLabel setEditable:NO];
        [self.view addSubview:self.lightLabel];
        
        self.musicLabel = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(100, 30, 300, 30))];
        [self.musicLabel setTextColor:[NSColor whiteColor]];
        [self.musicLabel setAlignment:kCTTextAlignmentCenter];
        [self.musicLabel setFont:[NSFont systemFontOfSize:25]];
        [self.musicLabel setBackgroundColor:[NSColor clearColor]];
        [self.musicLabel setDrawsBackground:NO];
        [self.musicLabel setBezeled:NO];
        [self.musicLabel setEditable:NO];
        [self.view addSubview:self.musicLabel];

        self.lockLabel = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(100, 60, 300, 30))];
        [self.lockLabel setTextColor:[NSColor whiteColor]];
        [self.lockLabel setAlignment:kCTTextAlignmentCenter];
        [self.lockLabel setFont:[NSFont systemFontOfSize:25]];
        [self.lockLabel setBackgroundColor:[NSColor clearColor]];
        [self.lockLabel setDrawsBackground:NO];
        [self.lockLabel setBezeled:NO];
        [self.lockLabel setEditable:NO];
        [self.lockLabel setStringValue:@"Not Locked"];
        [self.view addSubview:self.lockLabel];
        

        self.latestCommandLabel = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(100, 90, 300, 30))];
        [self.latestCommandLabel setTextColor:[NSColor whiteColor]];
        [self.latestCommandLabel setAlignment:kCTTextAlignmentCenter];
        [self.latestCommandLabel setFont:[NSFont systemFontOfSize:25]];
        [self.latestCommandLabel setBackgroundColor:[NSColor clearColor]];
        [self.latestCommandLabel setDrawsBackground:NO];
        [self.latestCommandLabel setBezeled:NO];
        [self.latestCommandLabel setEditable:NO];
        [self.latestCommandLabel setStringValue:@"No command"];
        [self.view addSubview:self.latestCommandLabel];

    }
    return self;
}

-(void)loadView
{
    [super loadView];
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

-(void)setLatestCommand:(NSString *)latestCommand
{
    self.latestCommandLabel.stringValue = latestCommand;
}

-(void)setMode:(MYHMode)mode
{
    switch (mode) {
        case MYHModeLights:
            [self.latestCommandLabel setStringValue:@"Toggled To Lights Mode"];
            [self.lightLabel setStringValue:@"Lights Mode On"];
            [self.musicLabel setStringValue:@"Music Mode Off"];
            break;
        case MYHModeMusic:
            [self.latestCommandLabel setStringValue:@"Toggled To Music Mode"];
            [self.musicLabel setStringValue:@"Music Mode On"];
            [self.lightLabel setStringValue:@"Lights Mode Off"];
            break;
        default:
            break;
    }
    _mode = mode;
    [self.myMyo startUpdate];
    NSString *messageBody = [NSString stringWithFormat: @"{\"alert\":\"select\"}"];
    [self.lights updateHueWithMessageBody:messageBody];
}

@end
