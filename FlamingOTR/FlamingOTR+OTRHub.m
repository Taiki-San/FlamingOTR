//
//  FlamingOTR+OTRHub.m
//  FlamingOTR
//
//  Created by Taiki on 25/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include "libotr.h"

@implementation FlamingOTR (OTRHub)

- (void) needActivateOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button
{
	FlamingOTRAccount * account = [self getContextForAccount:[FlamingOTRAccount accountFromCVC:conversation]];
	FlamingOTRSession * session = [account sessionWithController:conversation];

	if(session.isChangingSecureState)
		return;
	
	session.changeSecureState = YES;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[self initiateOTRSession:conversation fromButton:button];
		
	});
}

- (void) needDisableOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button
{
	FlamingOTRAccount * account = [self getContextForAccount:[FlamingOTRAccount accountFromCVC:conversation]];
	FlamingOTRSession * session = [account sessionWithController:conversation];
	
	if(session.isChangingSecureState)
		return;
	
	session.changeSecureState = YES;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[self killOTRSession:session];

	});
}

- (void) needRefreshOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button
{
	FlamingOTRAccount * account = [self getContextForAccount:[FlamingOTRAccount accountFromCVC:conversation]];
	FlamingOTRSession * session = [account sessionWithController:conversation];
	
	if(session.isChangingSecureState)
		return;
	
	session.changeSecureState = YES;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		[self reloadOTRSession:session];
		
	});
}

- (void) needValidateOTRForConversation : (FGOChatViewController *) conversation withOption : (byte) option
{
	
}

- (void) showDetailsOfOTRForConversation : (FGOChatViewController *) conversation
{
	
}

@end
