//
//  ApplicationDelegate.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/11/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "ApplicationDelegate.h"


@implementation ApplicationDelegate

-(void)initDefaults {
    NSMutableDictionary *d=[[NSMutableDictionary alloc] initWithCapacity:1];
    [d setObject:@"localhost:9988" forKey:@"location"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:d];
}

-(void)applicationDidFinishLaunching:(id)sender {
    NSLog(@"Application did finish launching.");
    [[NSNotificationCenter defaultCenter]
        postNotificationName: @"connect"
        object: [[NSUserDefaults standardUserDefaults] objectForKey:@"location"]];
}

@end
