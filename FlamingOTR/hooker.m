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
		[FlamingOTR swizzleClass:classHandle
				  originalMethod:@selector(loadView)
					  withMethod:@selector(fgochatviewcontroller_loadView)
					   fromClass:[FlamingHook class]];
	}
	else
	{
		NSLog(@"Couldn't inject into FGOChatViewController. Class not found");
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


