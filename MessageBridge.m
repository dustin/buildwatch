//
//  MessageBridge.m
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "MessageBridge.h"
#import "Master.h"
#import "Builder.h"
#import "keyboard_leds.h"
 
@implementation MessageBridge

-(id)init {
    id rv=[super init];
    masters=[[NSMutableDictionary alloc] initWithCapacity:10];
    return rv;
}

-(Master*)master:(NSString *)name {
    Master *m = [masters objectForKey:name];
    if (m == nil) {
        m = [[Master alloc] initWithName:name];
        [masters setObject:m forKey:name];
        [builders setContent: [masters allValues]];
        [m release];
        NSLog(@"Created new master: %@", name);
    }
    return m;
}

-(Category*)category:(NSString *)name onMaster:(NSString *)master {
    return [[self master: master] category: name];
}

-(void)builderAdded:(NSString *)buildername onMaster:(NSString *)master {
    NSLog(@"Added builder %@ from %@", buildername, master);
    Builder *b=[[Builder alloc] init];
    [b setName:buildername];

    [[self master: master] builderAdded: b];
    [outlineView reloadItem:nil reloadChildren:YES];
}

-(void)removeBuilder:(Builder*)builder
          fromMaster:(NSString*)master
        fromCategory:(NSString *)catName {
    Master *m = [self master:master];
    [m removeBuilder:builder fromCategory:catName];
    if ([m numChildren] == 0) {
        NSLog(@"Disposing of empty master:  %@", catName);
        [masters removeObjectForKey: catName];
        [builders setContent: [masters allValues]];
        [outlineView reloadItem:nil reloadChildren:YES];
    }
}

-(void)builderCategorized:(NSString *)buildername
                 onMaster:(NSString *)master
                 category:(NSString *)cat {
    [[self master:master] builderCategorized:buildername category:cat];
    [outlineView reloadItem:nil reloadChildren:YES];
}

-(void)builderRemoved:(NSString *)buildername
           fromMaster:(NSString *)master {
    [[self master:master] builderRemoved:buildername];
    [outlineView reloadItem:nil reloadChildren:YES];
}

-(void)disconnected:(id)sender {
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    [masters removeAllObjects];
    [builders setContent:nil];
    [pool release];
}

-(void)builderChangedState:(NSString *)buildername
                  onMaster:(NSString *)master
                     state:(NSString *)state
                       eta:(NSString *)eta {
    [[self master:master] builderChangedState:buildername
                                        state:state
                                          eta:eta];
}

-(void)buildStarted:(NSString *)buildername
           onMaster:(NSString *)master {
    [[self master:master] buildStarted:buildername];
}

-(void)gotBuildResult:(NSString *)buildername
             onMaster:(NSString *)master
               result:(int)result {
    [[self master:master] gotBuildResult:buildername result:result];
}

-(void)gotURL:(NSString *)url
   forBuilder:(NSString *)buildername
     onMaster:(NSString *)master {
    [[self master:master] gotURL:url forBuilder:buildername];
}

-(void)buildFinished:(NSString *)buildername
            onMaster:(NSString *)master
              result:(int)result {
    [[self master:master] buildFinished:buildername result:result];
}

-(void)buildETAUpdate:(NSString *)buildername
             onMaster:(NSString *)master
                  eta:(NSString *)eta {
    [[self master:master] buildETAUpdate:buildername eta:eta];
}

-(void)stepStarted:(NSString *)buildername
          onMaster:(NSString *)master
          stepname:(NSString *)stepname {
    [[self master:master] stepStarted:buildername stepname:stepname];
}

-(void)stepFinished:(NSString *)buildername
           onMaster:(NSString *)master
           stepname:(NSString *)stepname
             result:(int)result {
    [[self master:master] stepFinished:buildername
                              stepname:stepname
                                result:result];
}

-(void)stepETAUpdate:(NSString *)buildername
            onMaster:(NSString *)master
            stepname:(NSString *)stepname
                 eta:(NSString *)eta {
    [[self master:master] stepETAUpdate:buildername stepname:stepname eta:eta];
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
