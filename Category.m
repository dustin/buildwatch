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
    return nil;
}

-(NSArray*)items {
    return [builderDict allValues];
}

-(int)numChildren {
    return [builderDict count];
}

-(id)color {
    return [NSColor blackColor];
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
}

-(void)removeBuilder:(Builder*)builder {
    [self willChangeValueForKey:@"items"];
    [self willChangeValueForKey:@"numChildren"];
    [builderDict removeObjectForKey: [builder name]];
    [self didChangeValueForKey:@"numChildren"];
    [self didChangeValueForKey:@"items"];
}

@end
