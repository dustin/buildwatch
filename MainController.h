//
//  MainController.h
//  BuildWatch
//
//  Created by Dustin Sallings on 3/11/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainController : NSWindowController {

    IBOutlet NSTreeController *treeController;
    IBOutlet NSTextField *clock;

}

-(IBAction)onDoubleClick:(id)sender;
-(IBAction)turnOffCapsLock:(id)sender;

@end
