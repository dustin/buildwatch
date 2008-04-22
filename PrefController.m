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
    if(NSRunAlertPanel(@"Restart Required",
                    @"Because I'm lame, you must restart this application for your changes to take effect.",
                    @"Quit", @"Don't Quit", nil)) {
            [NSApp stop:self];
     }
}

@end
