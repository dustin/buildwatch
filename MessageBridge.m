//
//  MessageBridge.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "MessageBridge.h"


@implementation MessageBridge

-(void)builderAdded:(NSString *)buildername {
    NSLog(@"Added builder %@", buildername);
}

-(void)builderRemoved:(NSString *)buildername {
    NSLog(@"Removed builder %@", buildername);
}

-(void)builderChangedState:(NSString *)buildername state:(NSString *)state eta:(NSString *)eta {
    NSLog(@"Builder %@ changed state to %@.  Eta is %@", buildername, state, eta);
}

-(void)buildStarted:(NSString *)buildername {
    NSLog(@"A build started on %@", buildername);
}

-(void)buildFinished:(NSString *)buildername results:(NSString *)results {
    NSLog(@"A build finished on %@ -- results: %@", buildername, results);
}

-(void)buildETAUpdate:(NSString *)buildername eta:(NSString *)eta {
    NSLog(@"ETA update for %@: %@", buildername, eta);
}

-(void)stepStarted:(NSString *)buildername stepname:(NSString *)stepname {
    NSLog(@"Build %@ started step %@", buildername, stepname);
}

-(void)stepFinished:(NSString *)buildername
    stepname:(NSString *)stepname results:(NSString *)results {
    NSLog(@"Build %@ completed step %@ with %@", buildername, stepname, results);
}

-(void)stepETAUpdate:(NSString *)buildername
    stepname:(NSString *)stepname eta:(NSString *)eta {
    NSLog(@"Step ETA update for %@ on %@: %@", stepname, buildername, eta);
}

@end
