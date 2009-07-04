//
//  Builder.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "Builder.h"


@implementation Builder

-(BOOL)isLeaf {
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[Builder: %@]", name];
}

- (NSString *)name {
    return [[name retain] autorelease];
}

- (void)setName:(NSString *)value {
    if (name != value) {
        [name release];
        name = [value copy];
    }
}

- (NSString *)category {
    return [[category retain] autorelease];
}

- (void)setCategory:(NSString *)value {
    if (category != value) {
        [category release];
        category = [value copy];
    }
}

- (NSString *)state {
    return [[state retain] autorelease];
}

- (void)setState:(NSString *)value {
    if (state != value) {
        [state release];
        state = [value copy];
    }
}

- (NSString *)step {
    return [[step retain] autorelease];
}

- (void)setStep:(NSString *)value {
    if (step != value) {
        [step release];
        step = [value copy];
    }
}

- (NSString *)status {
    return [[status retain] autorelease];
}

- (void)setStatus:(NSString *)value {
    if (status != value) {
        [self willChangeValueForKey:@"color"];
        [status release];
        status = [value copy];
            [self didChangeValueForKey:@"color"];
    }
}

- (NSDate *)eta {
    return [[eta retain] autorelease];
}

- (void)setEta:(NSDate *)value {
    if (eta != value) {
        [eta release];
        eta = [value copy];
    }
}

- (NSDate *)stepeta {
    return [[stepeta retain] autorelease];
}

- (void)setStepeta:(NSDate *)value {
    if (stepeta != value) {
        [stepeta release];
        stepeta = [value copy];
    }
}

- (int)lastBuildResult {
    return lastBuildResult;
}

- (void)setLastBuildResult:(int)value {
    if (lastBuildResult != value) {
        [self willChangeValueForKey:@"color"];
        lastBuildResult = value;
        [self didChangeValueForKey:@"color"];
    }
}

- (NSColor *)color {
    NSColor *rv;
    if([status isEqualToString:@"idle"]) {
        if(lastBuildResult == BUILDBOT_SUCCESS) {
            rv=[NSColor blackColor];
        } else if(lastBuildResult == BUILDBOT_WARNING) {
            rv=[NSColor orangeColor];
        } else {
            rv=[NSColor redColor];
        }
    } else if([status isEqualToString:@"offline"]) {
        rv = [NSColor redColor];
    } else {
        rv=[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    }
    return rv;
}

@end
