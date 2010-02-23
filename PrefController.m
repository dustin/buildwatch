//
//  PrefController.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/10/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "PrefController.h"
#import "ApplicationDelegate.h"

@implementation PrefController

- (IBAction) savePrefs:(id)sender {
	NSLog(@"Saving preferences.");
	[defController save:self];

    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[NSApp delegate]
                                   selector:@selector(reconnectAll)
                                   userInfo:nil repeats:NO];
    [[self window] orderOut:self];
}

@end
