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
	NSNumber * token = [self getNewTokenForConversation:conversation];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[self initiateOTRSession:conversation];
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			
			if([self isToken:token validForConversation:conversation])
				button.locked = [self getOTRSessionStatus:conversation];
		});
	});
}

- (void) needDisableOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button
{
	NSNumber * token = [self getNewTokenForConversation:conversation];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[self killOTRSession:conversation];
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			
			if([self isToken:token validForConversation:conversation])
				button.locked = [self getOTRSessionStatus:conversation];
		});
	});
}

- (void) needRefreshOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button
{
	NSNumber * token = [self getNewTokenForConversation:conversation];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Interrupt potential session
		if(button.locked == YES)
			[self killOTRSession:conversation];
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			
			if([self isToken:token validForConversation:conversation])
				button.locked = [self getOTRSessionStatus:conversation];
		});
		
		[self initiateOTRSession:conversation];
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			
			if([self isToken:token validForConversation:conversation])
				button.locked = [self getOTRSessionStatus:conversation];
		});
	});
}

- (void) needValidateOTRForConversation : (FGOChatViewController *) conversation withOption : (byte) option
{
	
}

- (void) showDetailsOfOTRForConversation : (FGOChatViewController *) conversation
{
	
}

@end
