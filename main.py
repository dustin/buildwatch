#
#  main.py
#  BuildWatch
#
#  Created by Dustin Sallings on 2/28/08.
#  Copyright Dustin Sallings <dustin@spy.net> 2008. All rights reserved.
#

#import modules required by application
import objc
import Foundation
import AppKit

from PyObjCTools import AppHelper

# import modules containing classes required to start application and load MainMenu.nib
import BuildWatchAppDelegate

# pass control to AppKit
AppHelper.runEventLoop()
