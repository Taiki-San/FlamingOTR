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
		NSLog(@"Couldn't inject into %@. Class not found", coreClass);
	}
}

void cleanup()
{
	NSLog(@"Exiting nicely");
}


