//
//  Master.h
//  BuildWatch
//
//  Created by Dustin Sallings on 2/22/10.
//  Copyright 2010 Northscale. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Category.h"

@interface Master : NSObject {
    NSMutableDictionary *categoryDict;
    NSMutableDictionary *builderDict;
    NSColor *color;

    NSString *name;
}

-(id) initWithName:(NSString *)catName;

-(void)addCategory:(Category*)category;
-(void)removeCategory:(Category*)category;

-(void)removeBuilder:(Builder *)builder
        fromCategory:(NSString *)catName;

-(void)builderCategorized:(NSString *)builderName
                 category:(NSString *)cat;

-(void)builderRemoved:(NSString *)buildername;

-(void)builderChangedState:(NSString *)buildername
                     state:(NSString *)state
                       eta:(NSString *)eta;

-(void)buildStarted:(NSString *)buildername;

-(void)gotBuildResult:(NSString *)buildername
               result:(int)result;

-(void)gotURL:(NSString *)url
   forBuilder:(NSString *)buildername;

-(void)buildFinished:(NSString *)buildername
              result:(int)result;

-(void)buildETAUpdate:(NSString *)buildername
                  eta:(NSString *)eta;

-(void)stepStarted:(NSString *)buildername
          stepname:(NSString *)stepname;

-(void)stepFinished:(NSString *)buildername
           stepname:(NSString *)stepname
             result:(int)result;

-(void)stepETAUpdate:(NSString *)buildername
            stepname:(NSString *)stepname
                 eta:(NSString *)eta;

-(Category*)category:(NSString *)name;
-(void)builderAdded:(Builder *)builder;

-(NSString*)name;

-(int)numChildren;
-(NSArray*)items;

-(NSColor *)color;
-(void)setColor:(NSColor *)color;

@end
