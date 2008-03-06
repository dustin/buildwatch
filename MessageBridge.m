//
//  MessageBridge.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "MessageBridge.h"
#import "Builder.h"

@implementation MessageBridge

-(id)init {
    id rv=[super init];
    builderDict=[[NSMutableDictionary alloc] initWithCapacity:10];
    return rv;
}

-(void)builderAdded:(NSString *)buildername {
    NSLog(@"Added builder %@", buildername);
    Builder *b=[[Builder alloc] init];
    [b setName:buildername];
    [builders addObject:b];
    [builderDict setObject:b forKey:buildername];
    NSLog(@"Current builders:  %@", builders);
}

-(void)builderRemoved:(NSString *)buildername {
    NSLog(@"Removed builder %@", buildername);
}

-(void)builderChangedState:(NSString *)buildername state:(NSString *)state eta:(NSString *)eta {
    NSLog(@"Builder %@ changed state to %@.  Eta is %@", buildername, state, eta);
    [[builderDict valueForKey:buildername] setStatus:state];
}

-(void)buildStarted:(NSString *)buildername {
    NSLog(@"A build started on %@", buildername);
}

-(void)buildFinished:(NSString *)buildername result:(int)result {
    NSLog(@"A build finished on %@ -- results: %@", buildername, result);
    Builder *b=[builderDict valueForKey:buildername];
    [b setLastBuildResult:result];
    [b setEta:nil];
    [b setStepeta:nil];
}

-(void)buildETAUpdate:(NSString *)buildername eta:(NSString *)eta {
    NSLog(@"ETA update for %@: %@", buildername, eta);
    if(eta != nil) {
        Builder *b=[builderDict valueForKey:buildername];
        [b setEta:[NSDate dateWithTimeIntervalSinceNow: [eta doubleValue]]];
    }
}

-(void)stepStarted:(NSString *)buildername stepname:(NSString *)stepname {
    NSLog(@"Build %@ started step %@", buildername, stepname);
    [[builderDict valueForKey:buildername] setStep:stepname];
}

-(void)stepFinished:(NSString *)buildername
    stepname:(NSString *)stepname result:(int)result {
    NSLog(@"Build %@ completed step %@ with %d", buildername, stepname, result);
    [[builderDict valueForKey:buildername] setStep:nil];
}

-(void)stepETAUpdate:(NSString *)buildername
    stepname:(NSString *)stepname eta:(NSString *)eta {
    NSLog(@"Step ETA update for %@ on %@: %@", stepname, buildername, eta);
    if(eta != nil) {
        Builder *b=[builderDict valueForKey:buildername];
        [b setStepeta:[NSDate dateWithTimeIntervalSinceNow: [eta doubleValue]]];
    }
}

@end
