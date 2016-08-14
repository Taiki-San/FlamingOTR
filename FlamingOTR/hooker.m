//
//  hooker.m
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include <objc/runtime.h>

static void __attribute__((constructor)) initialize(void);
static void __attribute__((destructor)) cleanup(void);

void initialize()
{
	//Hook the UI initialization to add the lock button
	Class classHandle = objc_getClass("FGOChatViewController");
	if(classHandle != nil)
	{
		[FlamingHook swizzleClass:classHandle
				   originalMethod:@selector(loadView)
					   withMethod:@selector(fgochatviewcontroller_loadView)
						fromClass:[FlamingHook class]];
	}
	else
	{
		NSLog(@"Couldn't inject into FGOChatViewController. Class not found");
	}
	
	//Hook the status message insertion
	classHandle = objc_getClass("FGOChatPresenceTableCellView");
	if(classHandle != nil)
	{
		[FlamingHook swizzleClass:classHandle
				   originalMethod:@selector(viewDidMoveToWindow)
					   withMethod:@selector(FGOChatPresenceTableCellView_viewDidMoveToWindow)
						fromClass:[FlamingHook class]];
	}
	else
	{
		NSLog(@"Couldn't inject into FGOChatPresenceTableCellView. Class not found");
	}
	
	//Hook the network interface
	classHandle = objc_getClass("FGOIMServiceConnection");
	if(classHandle != nil)
	{
		[FlamingHook swizzleClass:classHandle
				   originalMethod:@selector(sendMessage:fromAccount:)
					   withMethod:@selector(fgoIMServiceConnection_sendMessage:fromAccount:)
						fromClass:[FlamingHook class]];
		
		[FlamingHook swizzleClass:classHandle
				   originalMethod:@selector(client:didReceiveMessage:)
					   withMethod:@selector(fgoIMServiceConnection_client:didReceiveMessage:)
						fromClass:[FlamingHook class]];
	}
	else
	{
		NSLog(@"Couldn't inject into FGOIMServiceConnection. Class not found");
	}

	//Kill the analytics framework not to interfer with the data during test and because I don't like snitches
	classHandle = objc_getClass("BITHockeyManager");
	if(classHandle != nil)
	{
		//Get the handle to swizzle class methods
		classHandle = object_getClass(classHandle);
		if(classHandle != nil)
		{
			[FlamingHook swizzleClass:classHandle
					   originalMethod:@selector(sharedHockeyManager)
						   withMethod:@selector(nukeHockeyManager)
							fromClass:[FlamingHook class]];
		}
		else
		{
			NSLog(@"Couldn't inject into BITHockeyManager. Class not found");
		}
	}
	else
	{
		NSLog(@"Couldn't inject into BITHockeyManager. Class not found");
	}
}

Class classWithName(const char * name)
{
	return objc_getClass(name);
}

void cleanup()
{
	NSLog(@"Exiting nicely");
}


