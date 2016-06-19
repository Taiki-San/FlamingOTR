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

//Hook in FGOAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{

}

//Hook in FGOChatListViewController

- (void) FGOChatListViewController_loadView
{
	[self FGOChatListViewController_loadView];
}

//Hook into FGOConversationViewController
- (id) initFGOConversationViewController : (id) arg1 chatListViewController : (id) arg2
{
	self = [self initFGOConversationViewController:arg1 chatListViewController:arg2];
	
	return self;
}

@end
