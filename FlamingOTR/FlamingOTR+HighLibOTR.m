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

- (void) initiateOTRSession : (FGOChatViewController *) controller fromButton: (FOTRButton *) button
{
	//The core libOTR initialization should only be performed when necessary
	if(!initialized)
	{
		//We want to be sure that the initialization is only performed once, but should be re-tried if it fails.
		//Because of the second requirement, we can't rely on dispatch_once
		if(![NSThread isMainThread])
		{
			return dispatch_sync(dispatch_get_main_queue(), ^{[self initiateOTRSession:controller fromButton:button];	});
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
	
	FlamingOTRAccount * account = [self getContextForAccount:[FlamingOTRAccount accountFromCVC:controller]];
	FlamingOTRSession * session = [account sessionWithController:controller];
	
	if(session != nil && !session.isSecure)
	{
		if(button != nil)
			session.button = button;

		[self initiateOTRSession:session];
	}
}

- (void) initiateOTRSession:(FlamingOTRSession *) session
{
#ifdef LOG_EVERYTHING
	NSLog(@"Initiate OTR session from %@ with %@", session.account.username, session.buddyUsername);
#endif

	if(!initialized || session.button == nil || session.isSecure)
		return;
	
	char * message = otrl_proto_default_query_msg(session.account.username.UTF8String, get_policy(NULL, NULL));
	
	if(message != NULL)
	{
		//OTR initialization :o
		[session.account sendString:[NSString stringWithUTF8String:message] toSession:session];
		free(message);
	}
}

- (void) killOTRSession : (FlamingOTRSession *) session
{
#ifdef LOG_EVERYTHING
	NSLog(@"Stop OTR session from %@ with %@", session.account.username, session.buddyUsername);
#endif

	if(!initialized || session == nil || !session.isSecure)
		return;
	
	OtrlMessageAppOps jumptable = [FlamingOTRAccount getJumptable];
	
	otrl_message_disconnect_all_instances(session.account.OTRContext.OTRState, &jumptable, (__bridge void *) session.account, session.account.signature.UTF8String, DEFAULT_PROTOCOL, session.buddyUsername.UTF8String);

	session.secure = NO;
}

- (void) reloadOTRSession : (FlamingOTRSession *) session
{
	[self killOTRSession:session];
	[self initiateOTRSession:session];
}

@end
