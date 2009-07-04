//
//  MessageBridge.h
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Category.h"
#import "Growl-WithInstaller/GrowlApplicationBridge.h"

@interface MessageBridge : NSObject <GrowlApplicationBridgeDelegate> {

    IBOutlet NSTreeController *builders;
    IBOutlet NSOutlineView *outlineView;

    NSMutableDictionary *builderDict;
    NSMutableDictionary *categories;
}

-(void)builderAdded:(NSString *)buildername;
-(void)builderRemoved:(NSString *)buildername;

-(void)builderCategorized:(NSString *)buildername category:(NSString *)cat;

-(void)builderChangedState:(NSString *)buildername state:(NSString *)state eta:(NSString *)eta;

-(void)buildStarted:(NSString *)buildername;
-(void)buildFinished:(NSString *)buildername result:(int)result;
-(void)buildETAUpdate:(NSString *)buildername eta:(NSString *)eta;

-(void)stepStarted:(NSString *)buildername stepname:(NSString *)stepname;
-(void)stepFinished:(NSString *)buildername
    stepname:(NSString *)stepname result:(int)result;
-(void)stepETAUpdate:(NSString *)buildername
    stepname:(NSString *)stepname eta:(NSString *)eta;

-(Category*)category:(NSString *)cat;

@end
