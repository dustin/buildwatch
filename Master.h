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
    NSColor *color;

    NSString *name;
}

-(id) initWithName:(NSString *)catName;

-(void)addCategory:(Category*)category;
-(void)removeCategory:(Category*)category;

-(NSString*)name;

-(int)numChildren;
-(NSArray*)items;

-(NSColor *)color;

@end
