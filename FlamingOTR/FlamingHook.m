//
//  FlamingHook.m
//  FlamingOTR
//
//  Created by Taiki on 10/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#import "FlamingHook.h"

@implementation FlamingHook

+ (void) HEYLOOKATME : (NSString *) heyListen
{
	NSAlert * alert = [[NSAlert alloc] init];
	if(alert != nil)
	{
		alert.alertStyle = NSInformationalAlertStyle;
		alert.messageText = @"WE GOT CONTACT";
		
		alert.informativeText = heyListen;
		[alert addButtonWithTitle:@"Ok"];
		
		[alert runModal];
	}

}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	//	[FlamingHook HEYLOOKATME:@"We have code execution at runtime :)"];
}

- (void) fakeNewConversation
{
	[self fakeNewConversation];
	
	//self is now a FGOChatListViewController instance
}

- (id) initConversation : (id) arg1 chatListViewController : (id) arg2
{
	self = [self initConversation:arg1 chatListViewController:arg2];
	
	if(self != nil)
	{
		__block __weak id selfCopy = self;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			NSLog(@"%@, %@, %@", selfCopy, arg1, arg2);
		});
	}
	
	//Titlebar: (NSView*) [[(NSView*) [[(NSView*) [((NSWindowController*) [(id) NSApp.delegate mainWindowController]).window titleBarView] subviews] objectAtIndex:0] subviews] objectAtIndex:1]
	return self;
}

@end
