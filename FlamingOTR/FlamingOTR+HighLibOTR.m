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
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		<#code to be executed once#>
	});
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
