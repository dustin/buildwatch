//
//  Category.m
//  BuildWatch
//
//  Created by Dustin Sallings on 7/3/09.
//  Copyright 2009 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "Category.h"


@implementation Category

- (id)initWithName:(NSString *)catName {
    id rv = [super init];
    builderDict = [[NSMutableDictionary alloc] initWithCapacity: 10];
    name = [catName retain];
    [self setColor: [NSColor blackColor]];
    return rv;
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

-(NSString *)eta {
    NSDate *rv = nil;

    NSEnumerator *enumerator = [builderDict objectEnumerator];
    id b;
    while ((b = [enumerator nextObject]) != nil) {
        NSDate *builderDate = [b eta];
        if (rv == nil) {
            rv = builderDate;
        } else if (builderDate != nil) {
            rv = [rv laterDate: builderDate];
        }
    }
    return rv;
}

-(NSArray*)items {
    return [builderDict allValues];
}

-(int)numChildren {
    return [builderDict count];
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

-(void)addBuilder:(Builder*)builder {
    [self willChangeValueForKey:@"items"];
    [self willChangeValueForKey:@"numChildren"];
    [builderDict setObject:builder forKey:[builder name]];
    [self didChangeValueForKey:@"numChildren"];
    [self didChangeValueForKey:@"items"];

    [builder addObserver:self
              forKeyPath:@"color"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:NULL];
    [builder addObserver:self
              forKeyPath:@"eta"
                 options:(NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld)
                 context:NULL];
}

-(void)removeBuilder:(Builder*)builder {
    [self willChangeValueForKey:@"items"];
    [self willChangeValueForKey:@"numChildren"];
    [builderDict removeObjectForKey: [builder name]];
    [self didChangeValueForKey:@"numChildren"];
    [self didChangeValueForKey:@"items"];

    [builder removeObserver:self forKeyPath:@"color"];
    [builder removeObserver:self forKeyPath:@"eta"];
}

- (BOOL)isBuilding
{
    BOOL rv = NO;
    NSEnumerator *enumerator = [builderDict objectEnumerator];
    id b;
    while ((b = [enumerator nextObject]) != nil) {
        rv = rv || [b isBuilding];
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
    NSEnumerator *enumerator = [builderDict objectEnumerator];
    id b;
    while ((b = [enumerator nextObject]) != nil) {
        status = MAX(status, [b lastBuildResult]);
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
