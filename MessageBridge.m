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
}

-(void)builderRemoved:(NSString *)buildername {
    NSLog(@"Removed builder %@", buildername);
    [builders removeObject: [builderDict objectForKey:buildername]];
    [builderDict removeObjectForKey:buildername];
}

-(void)disconnected:(id)sender {
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    [builders removeObjects:[builderDict allValues]];
    [builderDict removeAllObjects];
    [pool release];
}

-(void)builderChangedState:(NSString *)buildername state:(NSString *)state eta:(NSString *)eta {
    NSLog(@"Builder %@ changed state to %@.  Eta is %@", buildername, state, eta);
    [[builderDict valueForKey:buildername] setStatus:state];
}

-(void)buildStarted:(NSString *)buildername {
    NSLog(@"A build started on %@", buildername);
    [GrowlApplicationBridge
        notifyWithTitle:@"Starting Build"
        description:buildername
        notificationName:@"BuildStarted"
        iconData:nil
        priority:0
        isSticky:NO
        clickContext:nil];
}

-(void)buildFinished:(NSString *)buildername result:(int)result {
    NSLog(@"A build finished on %@ -- result: %d", buildername, result);
    Builder *b=[builderDict valueForKey:buildername];
    [b setLastBuildResult:result];
    [b setEta:nil];
    [b setStepeta:nil];
    if(result == 0) {
        [GrowlApplicationBridge
            notifyWithTitle:@"Completed Build"
            description:buildername
            notificationName:@"BuildSuccess"
            iconData:nil
            priority:0
            isSticky:NO
            clickContext:nil];
    } else {
        [GrowlApplicationBridge
            notifyWithTitle:@"Build Faiure"
            description:buildername
            notificationName:@"BuildFailed"
            iconData:nil
            priority:2
            isSticky:YES
            clickContext:nil];
    }
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
    [GrowlApplicationBridge
        notifyWithTitle:@"Started Step"
        description:[NSString stringWithFormat:@"Step %@ on builder %@", stepname, buildername]
        notificationName:@"StepStarted"
        iconData:nil
        priority:0
        isSticky:NO
        clickContext:nil];
}

-(void)stepFinished:(NSString *)buildername
    stepname:(NSString *)stepname result:(int)result {
    NSLog(@"Build %@ completed step %@ with %d", buildername, stepname, result);
    [[builderDict valueForKey:buildername] setStep:nil];
    if(result == 0) {
        [GrowlApplicationBridge
            notifyWithTitle:@"Completed Step"
            description:[NSString stringWithFormat:@"Step %@ on builder %@", stepname, buildername]
            notificationName:@"StepSuccess"
            iconData:nil
            priority:0
            isSticky:NO
            clickContext:nil];
    } else {
        [GrowlApplicationBridge
            notifyWithTitle:@"Step Faiure"
            description:[NSString stringWithFormat:@"Step %@ on builder %@", stepname, buildername]
            notificationName:@"StepFailed"
            iconData:nil
            priority:2
            isSticky:YES
            clickContext:nil];
    }
}

-(void)stepETAUpdate:(NSString *)buildername
    stepname:(NSString *)stepname eta:(NSString *)eta {
    NSLog(@"Step ETA update for %@ on %@: %@", stepname, buildername, eta);
    if(eta != nil) {
        Builder *b=[builderDict valueForKey:buildername];
        [b setStepeta:[NSDate dateWithTimeIntervalSinceNow: [eta doubleValue]]];
    }
}

- (NSDictionary *) registrationDictionaryForGrowl
{
    NSLog(@"Growl wants to know what kinda stuff we do.");

    NSArray *allNotifications=[[NSArray alloc] initWithObjects:
        @"BuildStarted", @"BuildSuccess", @"BuildFailed", @"StepStarted",
        @"StepSuccess", @"StepFailed", nil];
    NSArray *defaultNotifications=[[NSArray alloc] initWithObjects:
        @"BuildFailed", @"StepFailed", nil];

    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:
        allNotifications, GROWL_NOTIFICATIONS_ALL,
        defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT,
        nil];

    NSLog(@"Telling it %@", dict);

    [allNotifications release];
    [defaultNotifications release];
    [dict autorelease];
    return(dict);
}

-(void)growlIsReady
{
    NSLog(@"growl is ready");
}

-(NSString *)applicationNameForGrowl
{
    return(@"BuildWatch");
}

-(void)growlNotificationWasClicked:(id)clickContext
{
    NSLog(@"Hey!  Someone clicked on the notification:  %@", clickContext);
}

-(void)awakeFromNib {
    [GrowlApplicationBridge setGrowlDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(disconnected:) name:@"disconnected" object:nil];
}

@end
