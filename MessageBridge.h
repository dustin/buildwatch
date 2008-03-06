//
//  MessageBridge.h
//  BuildWatch
//
//  Created by Dustin Sallings on 3/5/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MessageBridge : NSObject {

}

-(void)builderAdded:(NSString *)buildername;
-(void)builderRemoved:(NSString *)buildername;

-(void)builderChangedState:(NSString *)buildername state:(NSString *)state eta:(NSString *)eta;

-(void)buildStarted:(NSString *)buildername;
-(void)buildFinished:(NSString *)buildername results:(NSString *)results;
-(void)buildETAUpdate:(NSString *)buildername eta:(NSString *)eta;

-(void)stepStarted:(NSString *)buildername stepname:(NSString *)stepname;
-(void)stepFinished:(NSString *)buildername
    stepname:(NSString *)stepname results:(NSString *)results;
-(void)stepETAUpdate:(NSString *)buildername
    stepname:(NSString *)stepname eta:(NSString *)eta;

@end
