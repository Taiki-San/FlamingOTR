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
	Class coreClass = objc_getClass("FGOAppDelegate");
	if(coreClass != nil)
	{
		[FlamingOTR addSelector:@selector(applicationWillFinishLaunching:) ofClass:[FlamingHook class] toClass:coreClass];
	}
	else
	{
		NSLog(@"Couldn't inject into FGOAppDelegate. Class not found");
	}
	
	Class primaryViewController = objc_getClass("FGOChatListViewController");
	if(primaryViewController != nil)
	{
		[FlamingOTR swizzleClass:primaryViewController
				  originalMethod:NSSelectorFromString(@"loadView")
					  withMethod:@selector(FGOChatListViewController_loadView)
					   fromClass:[FlamingHook class]];
	}
	else
	{
		NSLog(@"Couldn't inject into FGOChatListViewController. Class not found");
	}
	
	primaryViewController = objc_getClass("FGOConversationViewController");
	if(primaryViewController != nil)
	{
		[FlamingOTR swizzleClass:primaryViewController
				  originalMethod:NSSelectorFromString(@"initWithConversation:chatListViewController:")
					  withMethod:@selector(initFGOConversationViewController:chatListViewController:)
					   fromClass:[FlamingHook class]];
	}
	else
	{
		NSLog(@"Couldn't inject into FGOConversationViewController. Class not found");
	}
}

void cleanup()
{
	NSLog(@"Exiting nicely");
}


