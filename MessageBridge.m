//
//  MessageBridge.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "MessageBridge.h"
#import "Builder.h"
#import "keyboard_leds.h"

@implementation MessageBridge

-(id)init {
    id rv=[super init];
    builderDict=[[NSMutableDictionary alloc] initWithCapacity:10];
    categories=[[NSMutableDictionary alloc] initWithCapacity:10];
    return rv;
}

-(Category*)category:(NSString *)name onMaster:(NSString *)master {
    Category *rv = [categories objectForKey:name];
    if (rv == nil) {
        rv = [[Category alloc] initWithName: name];
        [categories setObject:rv forKey:name];

        [builders setContent: [categories allValues]];

        [rv release];
        NSLog(@"Created new category:  %@", name);
    }
    return rv;
}

-(void)builderAdded:(NSString *)buildername onMaster:(NSString *)master {
    NSLog(@"Added builder %@", buildername);
    Builder *b=[[Builder alloc] init];
    [b setName:buildername];
    [builderDict setObject:b forKey:buildername];
}

-(void)removeBuilder:(Builder*)builder
          fromMaster:(NSString*)master
        fromCategory:(NSString *)catName {
    Category *cat = [categories objectForKey: catName];
    if (cat) {
        NSLog(@"Removing %@ from category %@", [builder name], catName);
        [cat removeBuilder: builder];
        if ([cat numChildren] == 0) {
            NSLog(@"Disposing of empty category:  %@", catName);
            [categories removeObjectForKey: catName];
            [builders setContent: [categories allValues]];
            [outlineView reloadItem:nil reloadChildren:YES];
        }
    }
}

-(void)builderCategorized:(NSString *)buildername
                 onMaster:(NSString *)master
                 category:(NSString *)cat {
    NSLog(@"Categorized builder %@ as %@", buildername, cat);
    Builder *builder = [builderDict valueForKey:buildername];

    [self removeBuilder:builder fromMaster:master fromCategory:[builder category]];
    [builder setCategory:cat];
    [[self category:cat onMaster:master] addBuilder: builder];
}

-(void)builderRemoved:(NSString *)buildername
           fromMaster:(NSString *)master {
    NSLog(@"Removed builder %@", buildername);
    [builders removeObject: [builderDict objectForKey:buildername]];
    [builderDict removeObjectForKey:buildername];
}

-(void)disconnected:(id)sender {
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    [categories removeAllObjects];
    [builderDict removeAllObjects];
    [builders setContent:nil];
    [pool release];
}

-(void)builderChangedState:(NSString *)buildername
                  onMaster:(NSString *)master
                     state:(NSString *)state
                       eta:(NSString *)eta {
    NSLog(@"Builder %@ changed state to %@.  Eta is %@", buildername, state, eta);
    [[builderDict valueForKey:buildername] setStatus:state];
}

-(void)buildStarted:(NSString *)buildername
           onMaster:(NSString *)master {
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

-(void)gotBuildResult:(NSString *)buildername
             onMaster:(NSString *)master
               result:(int)result {
    Builder *b=[builderDict valueForKey:buildername];
    [b setLastBuildResult:result];
}

-(void)gotURL:(NSString *)url
   forBuilder:(NSString *)buildername
     onMaster:(NSString *)master {
    NSLog(@"Got URL:  %@ for builder:  %@", url, buildername);
    Builder *b=[builderDict valueForKey:buildername];
    [b setURL: url];
}

-(void)buildFinished:(NSString *)buildername
            onMaster:(NSString *)master
              result:(int)result {
    NSLog(@"A build finished on %@ -- result: %d", buildername, result);
    Builder *b=[builderDict valueForKey:buildername];
    [b setLastBuildResult:result];
    [b setEta:nil];
    [b setStepeta:nil];
    if(result == BUILDBOT_SUCCESS) {
        [GrowlApplicationBridge
            notifyWithTitle:@"Completed Build"
            description:buildername
            notificationName:@"BuildSuccess"
            iconData:nil
            priority:0
            isSticky:NO
            clickContext:nil];
    } else if(result == BUILDBOT_WARNING) {
        [GrowlApplicationBridge
            notifyWithTitle:@"Warnings in Build"
            description:buildername
            notificationName:@"BuildWarnings"
            iconData:nil
            priority:1
            isSticky:NO
            clickContext:nil];
    } else {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"useCapsLock"]) {
            manipulate_led(kHIDUsage_LED_CapsLock, 1);
        }
        [GrowlApplicationBridge
            notifyWithTitle:@"Build Failure"
            description:buildername
            notificationName:@"BuildFailed"
            iconData:nil
            priority:2
            isSticky:YES
            clickContext:@"Failure Notice"];
    }
}

-(void)buildETAUpdate:(NSString *)buildername
             onMaster:(NSString *)master
                  eta:(NSString *)eta {
    NSLog(@"ETA update for %@: %@", buildername, eta);
    if(eta != nil) {
        Builder *b=[builderDict valueForKey:buildername];
        [b setEta:[NSDate dateWithTimeIntervalSinceNow: [eta doubleValue]]];
    }
}

-(void)stepStarted:(NSString *)buildername
          onMaster:(NSString *)master
          stepname:(NSString *)stepname {
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
           onMaster:(NSString *)master
           stepname:(NSString *)stepname
             result:(int)result {
    NSLog(@"Build %@ completed step %@ with %d", buildername, stepname, result);
    [[builderDict valueForKey:buildername] setStep:nil];
    if(result == BUILDBOT_SUCCESS) {
        [GrowlApplicationBridge
            notifyWithTitle:@"Completed Step"
            description:[NSString stringWithFormat:@"Step %@ on builder %@", stepname, buildername]
            notificationName:@"StepSuccess"
            iconData:nil
            priority:0
            isSticky:NO
            clickContext:nil];
    } else if(result == BUILDBOT_WARNING) {
        [GrowlApplicationBridge
            notifyWithTitle:@"Step Warning"
            description:[NSString stringWithFormat:@"Step %@ on builder %@", stepname, buildername]
            notificationName:@"StepWarning"
            iconData:nil
            priority:1
            isSticky:YES
            clickContext:nil];
    } else {
        [GrowlApplicationBridge
            notifyWithTitle:@"Step Failure"
            description:[NSString stringWithFormat:@"Step %@ on builder %@", stepname, buildername]
            notificationName:@"StepFailed"
            iconData:nil
            priority:2
            isSticky:YES
            clickContext:nil];
    }
}

-(void)stepETAUpdate:(NSString *)buildername
            onMaster:(NSString *)master
            stepname:(NSString *)stepname
                 eta:(NSString *)eta {
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
                                                   @"BuildStarted",
                                               @"BuildSuccess", @"BuildWarnings",
                                               @"BuildFailed", @"StepStarted",
                                               @"StepSuccess", @"StepWarning",
                                               @"StepFailed", nil];
    NSArray *defaultNotifications=[[NSArray alloc] initWithObjects:
                                                       @"BuildFailed",
                                                   @"BuildWarnings",
                                                   @"StepWarning",
                                                   @"StepFailed", nil];

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
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"useCapsLock"]) {
        manipulate_led(kHIDUsage_LED_CapsLock, 0);
    }
}

-(void)awakeFromNib {
    [GrowlApplicationBridge setGrowlDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(disconnected:) name:@"disconnected" object:nil];
}

@end
