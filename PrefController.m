//
//  PrefController.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/10/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "PrefController.h"


@implementation PrefController

- (IBAction) savePrefs:(id)sender {
	NSLog(@"Saving preferences.");
	[defController save:self];
    [[NSNotificationCenter defaultCenter]
        postNotificationName: @"disconnectAll" object: nil];
    [[NSNotificationCenter defaultCenter]
        postNotificationName: @"connect"
        object: [[NSUserDefaults standardUserDefaults] objectForKey:@"location"]];

	[[self window] orderOut:self];
}

@end
