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
	
	classHandle = objc_getClass("BITHockeyManager");
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

Class classWithName(const char * name)
{
	return objc_getClass(name);
}

void cleanup()
{
	NSLog(@"Exiting nicely");
}


