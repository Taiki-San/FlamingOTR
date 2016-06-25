//
//  FlamingHook.m
//  FlamingOTR
//
//  Created by Taiki on 10/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#import "FlamingHook.h"

@implementation FlamingHook

//Hook FGOChatViewController

- (void) fgochatviewcontroller_loadView
{
	[self fgochatviewcontroller_loadView];
	
	//We insert the OTR control button
	FGOChatViewController * controller = (id) self;
	
	FOTRButton * button = [[FOTRButton alloc] initButtonWithController:controller];
	if(button != nil)
	{
		button.coreListener = [FlamingOTR getShared];
		[controller.titleBarView addSubview:button];		//The button position is auto set as it already has to handle the container frame changes
	}
}

//Hook FGOIMServiceConnection
- (id) fgoIMServiceConnection_sendMessage:(FGOIMServiceMessage *) message fromAccount: (FGOAccount *) account
{
	if(message.body != nil && ![message.body hasPrefix:@"?OTR"])	//We don't want to process already OTRed strings
	{
//		[[FlamingOTR getShared] ]
		NSLog(@"Sent: %@ - %@ - %@", message.body, message.to.name, account.sanitizedUsername.lowercaseString);
		message.HTMLBody = nil;
	}
	
	return [self fgoIMServiceConnection_sendMessage:message fromAccount:account];
}

- (void)fgoIMServiceConnection_client:(id <FGOIMServiceClient>) client didReceiveMessage:(FGOIMServiceMessage *) message
{
	if(message.body != nil)
	{
		if([message.body hasPrefix:@"?OTR"])
		{
			NSLog(@"Received OTR message from %@", message.from.name);
			return;
		}
		//		[[FlamingOTR getShared] ]
		NSLog(@"Received: %@ to %@ from %@", message.body, message.to.name, message.from.name);
	}
	
	[self fgoIMServiceConnection_client:client didReceiveMessage:message];
}


//Nuke Hockey
- (id) nukeHockeyManager	{	return nil;	}

@end
