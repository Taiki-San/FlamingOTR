//
//  FlamingOTR+HighLibOTR.m
//  FlamingOTR
//
//  Created by Taiki on 25/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include "libotr.h"

@implementation FlamingOTR (HighLibOTR)

#pragma mark - Core OTR module

- (void) initiateOTRSession : (FGOChatViewController *) controller
{
	//The core libOTR initialization should only be performed when necessary
	if(!initialized)
	{
		//We want to be sure that the initialization is only performed once, but should be re-tried if it fails.
		//Because of the second requirement, we can't rely on dispatch_once
		if(![NSThread isMainThread])
		{
			return	dispatch_sync(dispatch_get_main_queue(), ^{[self initiateOTRSession:controller];	});
		}
		//Initialization routine based on the OTRL_INIT macro
		else if (otrl_init(OTRL_VERSION_MAJOR, OTRL_VERSION_MINOR, OTRL_VERSION_SUB))
		{
			return NSLog(@"Couldn't initialize libOTR!");
		}
		else
		{
			NSLog(@"FlamingOTR %s, powered by libotr %s", FLAMINGOTR_VERSION, otrl_version());
			initialized = YES;
		}
	}

	[self writeString:@"olololololololol" toHandle:controller];
	sleep(1);
}

- (void) killOTRSession : (FGOChatViewController *) controller
{
	sleep(1);
}

static BOOL lol = NO;
- (BOOL) getOTRSessionStatus : (FGOChatViewController *) controller
{
	return (lol = !lol);
}

@end
