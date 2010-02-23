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

    NSMutableDictionary *masters;
}

-(void)builderAdded:(NSString *)buildername
           onMaster:(NSString *)master;
-(void)builderRemoved:(NSString *)buildername
           fromMaster:(NSString *)master;

-(void)builderCategorized:(NSString *)buildername
                 onMaster:(NSString *)master
                 category:(NSString *)cat;

-(void)builderChangedState:(NSString *)buildername
                  onMaster:(NSString *)master
                     state:(NSString *)state
                       eta:(NSString *)eta;

-(void)buildStarted:(NSString *)buildername
           onMaster:(NSString *)master;
-(void)buildFinished:(NSString *)buildername
            onMaster:(NSString *)master
              result:(int)result;
-(void)buildETAUpdate:(NSString *)buildername
             onMaster:(NSString *)master
                  eta:(NSString *)eta;

-(void)stepStarted:(NSString *)buildername
          onMaster:(NSString *)master
          stepname:(NSString *)stepname;
-(void)stepFinished:(NSString *)buildername
           onMaster:(NSString *)master
           stepname:(NSString *)stepname
             result:(int)result;

-(void)stepETAUpdate:(NSString *)buildername
            onMaster:(NSString *)master
            stepname:(NSString *)stepname
                 eta:(NSString *)eta;

-(Category*)category:(NSString *)cat
            onMaster:(NSString *)master;

@end
