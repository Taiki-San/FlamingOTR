//
//  FlamingHook.m
//  FlamingOTR
//
//  Created by Taiki on 10/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#import "FlamingHook.h"

@implementation FlamingHook

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	NSAlert * alert = [[NSAlert alloc] init];
	if(alert != nil)
	{
		alert.alertStyle = NSInformationalAlertStyle;
		alert.messageText = @"WE GOT CONTACT";
		
		alert.informativeText = @"We have code execution at runtime :)";
		[alert addButtonWithTitle:@"Ok"];
		
		[alert runModal];
	}
}

@end
