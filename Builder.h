//
//  Builder.h
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define BUILDBOT_SUCCESS 0
#define BUILDBOT_WARNING 1
#define BUILDBOT_FAILURE 2

@interface Builder : NSObject {

    NSString *name;
    NSString *category;
    NSString *state;
    NSString *step;
    NSString *status;
    int lastBuildResult;
    NSDate *stepeta;
    NSDate *eta;

}

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)category;
- (void)setCategory:(NSString *)category;

- (NSString *)state;
- (void)setState:(NSString *)value;

- (NSString *)step;
- (void)setStep:(NSString *)value;

- (NSString *)status;
- (void)setStatus:(NSString *)value;

- (NSDate *)eta;
- (void)setEta:(NSDate *)value;

- (NSDate *)stepeta;
- (void)setStepeta:(NSDate *)value;

- (int)lastBuildResult;
- (void)setLastBuildResult:(int)value;

- (NSColor *)color;

@end
