//
//  PrefController.h
//  BuildWatch
//
//  Created by Dustin Sallings on 3/10/08.
//  Copyright 2008 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrefController : NSWindowController {

	IBOutlet NSUserDefaultsController *defController;

}

- (IBAction) savePrefs:(id)sender;

@end
