//
//  Master.m
//  BuildWatch
//
//  Created by Dustin Sallings on 2/22/10.
//  Copyright 2010 Northscale. All rights reserved.
//

#import "Master.h"
#import "Growl-WithInstaller/GrowlApplicationBridge.h"
#import "keyboard_leds.h"

@implementation Master

- (id)initWithName:(NSString *)masterName {
    id rv = [super init];
    categoryDict = [[NSMutableDictionary alloc] initWithCapacity: 10];
    builderDict=[[NSMutableDictionary alloc] initWithCapacity:10];
    name = [masterName retain];
    [self setColor: [NSColor blackColor]];
    return rv;
}

-(Category*)category:(NSString *)catname {
    Category *rv = [categoryDict objectForKey:catname];
    if (rv == nil) {
        rv = [[Category alloc] initWithName: catname];
        [categoryDict setObject:rv forKey:catname];

        [rv release];
        NSLog(@"Created new category:  %@", catname);
    }
    return rv;
}

-(void)builderAdded:(Builder *)builder {
    [builderDict setObject:builder forKey:[builder name]];
}

-(void)removeBuilder:(Builder *)builder
        fromCategory:(NSString *)catName {
    Category *cat = [categoryDict objectForKey: catName];
    if (cat) {
        NSLog(@"Removing %@ from category %@", [builder name], catName);
        [cat removeBuilder: builder];
        if ([cat numChildren] == 0) {
            NSLog(@"Disposing of empty category:  %@", catName);
            [categoryDict removeObjectForKey: catName];
        }
    }
}

-(void)builderCategorized:(NSString *)buildername
                 category:(NSString *)cat {
    NSLog(@"Categorized builder %@ as %@", buildername, cat);
    Builder *builder = [builderDict valueForKey:buildername];

    [self removeBuilder:builder fromCategory:[builder category]];
    [builder setCategory:cat];
    [[self category:cat] addBuilder: builder];
}

-(void)builderRemoved:(NSString *)buildername {
    NSLog(@"Removed builder %@", buildername);
    [builderDict removeObjectForKey:buildername];
}

-(void)builderChangedState:(NSString *)buildername
                     state:(NSString *)state
                       eta:(NSString *)eta {
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

-(void)gotBuildResult:(NSString *)buildername
               result:(int)result {
    Builder *b=[builderDict valueForKey:buildername];
    [b setLastBuildResult:result];
}

-(void)gotURL:(NSString *)url
   forBuilder:(NSString *)buildername {
    NSLog(@"Got URL:  %@ for builder:  %@", url, buildername);
    Builder *b=[builderDict valueForKey:buildername];
    [b setURL: url];
}

-(void)buildFinished:(NSString *)buildername
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
                  eta:(NSString *)eta {
    NSLog(@"ETA update for %@: %@", buildername, eta);
    if(eta != nil) {
        Builder *b=[builderDict valueForKey:buildername];
        [b setEta:[NSDate dateWithTimeIntervalSinceNow: [eta doubleValue]]];
    }
}

-(void)stepStarted:(NSString *)buildername
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
            stepname:(NSString *)stepname
                 eta:(NSString *)eta {
    NSLog(@"Step ETA update for %@ on %@: %@", stepname, buildername, eta);
    if(eta != nil) {
        Builder *b=[builderDict valueForKey:buildername];
        [b setStepeta:[NSDate dateWithTimeIntervalSinceNow: [eta doubleValue]]];
    }
}

-(NSString *)name {
    return [name retain];
}

-(NSString *)status {
    return nil;
}

-(NSString *)step {
    return nil;
}

-(NSString *)url {
    return nil;
}

-(NSDate *)eta {
    NSDate *rv = nil;

    NSEnumerator *enumerator = [categoryDict objectEnumerator];
    id c;
    while ((c = [enumerator nextObject]) != nil) {
        NSDate *categoryDate = [c eta];
        if (rv == nil) {
            rv = categoryDate;
        } else if (categoryDate != nil) {
            rv = [rv laterDate: categoryDate];
        }
    }
    return rv;
}

-(NSArray*)items {
    return [categoryDict allValues];
}

-(int)numChildren {
    return [categoryDict count];
}

-(BOOL)isLeaf {
    return NO;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;

    if ([theKey isEqualToString:@"items"]) {
        automatic=NO;
    } else if ([theKey isEqualToString:@"numChildren"]) {
        automatic=NO;
    } else {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }

    return automatic;
}

-(void)addCategory:(Category*)category {
    [self willChangeValueForKey:@"items"];
    [self willChangeValueForKey:@"numChildren"];
    [categoryDict setObject:category forKey:[category name]];
    [self didChangeValueForKey:@"numChildren"];
    [self didChangeValueForKey:@"items"];

    [category addObserver:self
               forKeyPath:@"color"
                  options:(NSKeyValueObservingOptionNew |
                           NSKeyValueObservingOptionOld)
                 context:NULL];
    [category addObserver:self
               forKeyPath:@"eta"
                  options:(NSKeyValueObservingOptionNew |
                           NSKeyValueObservingOptionOld)
                  context:NULL];
}

-(void)removeCategory:(Category*)category {
    [self willChangeValueForKey:@"items"];
    [self willChangeValueForKey:@"numChildren"];
    [categoryDict removeObjectForKey: [category name]];
    [self didChangeValueForKey:@"numChildren"];
    [self didChangeValueForKey:@"items"];

    [category removeObserver:self forKeyPath:@"color"];
    [category removeObserver:self forKeyPath:@"eta"];
}

- (BOOL)isBuilding
{
    BOOL rv = NO;
    NSEnumerator *enumerator = [categoryDict objectEnumerator];
    id c;
    while ((c = [enumerator nextObject]) != nil) {
        rv = rv || [c isBuilding];
    }
    return rv;
}

- (void)setColor:(NSColor *)to
{
    [color release];
    color = [to retain];
}

- (NSColor *)color
{
    return [[color retain] autorelease];
}

- (void)computeColor
{
    int status = 0;
    NSEnumerator *enumerator = [categoryDict objectEnumerator];
    id c;
    while ((c = [enumerator nextObject]) != nil) {
        status = MAX(status, [c lastBuildResult]);
    }

    if (status == BUILDBOT_FAILURE) {
        [self setColor:[NSColor redColor]];
    } else if (status == BUILDBOT_WARNING) {
        [self setColor:[NSColor orangeColor]];
    } else if ([self isBuilding]) {
        [self setColor:[NSColor colorWithCalibratedRed:0.0
                                                 green:0.5
                                                  blue:0.0
                                                 alpha:1.0]];
    } else if (status == BUILDBOT_SUCCESS) {
        [self setColor:[NSColor blackColor]];
    } else {
        [self setColor:[NSColor redColor]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"color"]) {
        [self computeColor];
    } else if ([keyPath isEqual:@"eta"]) {
        // This is always derived, so just declare it changed.
        [self willChangeValueForKey:@"eta"];
        [self didChangeValueForKey:@"eta"];
    }
}

@end
