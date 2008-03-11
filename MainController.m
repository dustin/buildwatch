//
//  MainController.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/11/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "MainController.h"


@implementation MainController

-(void)updateClock:(id)sender
{
    [clock setObjectValue:[NSDate date]];
}

-(void)awakeFromNib {
    NSLog(@"Awake!");
    [self updateClock:self];
    [NSTimer scheduledTimerWithTimeInterval:1.0
        target:self
        selector:@selector(updateClock:)
        userInfo:nil
        repeats:YES];
}

@end
