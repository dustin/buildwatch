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
    [d setObject:[NSNumber numberWithBool: YES] forKey:@"useCapsLock"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:d];
}

-(void)awakeFromNib {
	[self initDefaults];
}

-(void)applicationDidFinishLaunching:(id)sender {
    NSLog(@"Application did finish launching.");
    [self reconnectAll];
}

-(void)reconnectAll {
    [[NSNotificationCenter defaultCenter]
        postNotificationName: @"disconnectAll" object: nil];

    NSCharacterSet *seps = [NSCharacterSet characterSetWithCharactersInString:@", "];
    NSString *loc = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
    NSArray *locations = [loc componentsSeparatedByCharactersInSet:seps];

    NSEnumerator *enumerator = [locations objectEnumerator];
    id l;
    while ((l = [enumerator nextObject]) != nil) {
        [[NSNotificationCenter defaultCenter]
                postNotificationName: @"connect"
                              object: l];
    }
}

@end
