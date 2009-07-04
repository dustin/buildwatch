//
//  Category.h
//  BuildWatch
//
//  Created by Dustin Sallings on 7/3/09.
//  Copyright 2009 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Builder.h"

@interface Category : NSObject {

    NSMutableDictionary *builderDict;

    NSString *name;
}

-(id) initWithName:(NSString *)catName;

-(void)addBuilder:(Builder*)builder;
-(void)removeBuilder:(Builder*)builder;

-(NSString*)name;

-(int)numChildren;
-(NSArray*)items;

@end
