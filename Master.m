//
//  Master.m
//  BuildWatch
//
//  Created by Dustin Sallings on 2/22/10.
//  Copyright 2010 Northscale. All rights reserved.
//

#import "Master.h"


@implementation Master

- (id)initWithName:(NSString *)masterName {
    id rv = [super init];
    categoryDict = [[NSMutableDictionary alloc] initWithCapacity: 10];
    name = [masterName retain];
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

-(NSString *)url {
    return nil;
}

-(NSString *)eta {
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
