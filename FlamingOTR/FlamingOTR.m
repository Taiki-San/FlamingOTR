//
//  FlamingOTR.m
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include <objc/runtime.h>
#include <pthread/pthread.h>

#include "libotr/version.h"

static FlamingOTR * singleton = nil;

@interface FlamingOTR ()
{
	NSMutableDictionary * sessionController;
	
	pthread_mutex_t tokenMutex;
}

@end

@implementation FlamingOTR

+ (instancetype) getShared
{
	if(singleton == nil)
	{
		singleton = [[FlamingOTR alloc] init];
	}
	
	return singleton;
}

- (instancetype) init
{
	self = [super init];
	
	if(self != nil)
	{
		pthread_mutex_init(&tokenMutex, NULL);
		sessionController = [NSMutableDictionary new];
	}
	
	return self;
}

- (void) dealloc
{
	pthread_mutex_destroy(&tokenMutex);
}

#pragma mark - Access control

- (NSNumber *) getNewTokenForConversation : (FGOChatViewController *) conversation
{
	if(conversation == nil || conversation.handle == nil)
		return nil;
	
	pthread_mutex_lock(&tokenMutex);
	
	NSNumber * token = [sessionController objectForKey:@((uintptr_t) conversation.handle)];
	if(token == nil)
		token = @(1);
	else
		token = @([token unsignedIntValue] + 1);
	
	[sessionController setObject:token forKey:@((uintptr_t) conversation.handle)];
	
	pthread_mutex_unlock(&tokenMutex);
	
	return token;
}

- (BOOL) isToken : (NSNumber *) token validForConversation : (FGOChatViewController *) conversation
{
	if(token == nil || conversation == nil || conversation.handle == nil)
		return NO;
	
	pthread_mutex_lock(&tokenMutex);
	
	BOOL output = [[sessionController objectForKey:@((uintptr_t) conversation.handle)] isEqual:token];
	
	pthread_mutex_unlock(&tokenMutex);
	
	return output;
}

#pragma mark - Implement OTRHub

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

#pragma mark - Communication hub

- (void) sendString : (NSString *) string toHandle : (FGORosterHandleName *) handle
{
	[[classWithName("FGOIMServiceConnection") sharedInstance] sendMessage:[classWithName("FGOIMServiceMessage")
																		   messageWithBody:string
																		   toHandleWithName:handle.name
																		   withState:0]
															  fromAccount:handle.account];
}

- (void) writeString : (NSString *) string toHandle : (FGOChatViewController *) handle
{
	if (![NSThread isMainThread])
	{
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self writeString:string toHandle:handle];
		});
	}
	else
	{
		[handle.conversation insertChatMessageWithEntityName:@"FGOChatMessage"
													  string:string
														sent:YES
												  handleName:handle.handleName];
		
		[handle showMessages:@[handle.conversation.lastMessage]];
	}
}

#pragma mark - Core OTR module

- (void) initiateOTRSession : (FGOChatViewController *) controller
{
	[self writeString:@"olololololololol" toHandle:controller];
	sleep(1);
}

- (void) killOTRSession : (FGOChatViewController *) controller
{
	sleep(1);
}

BOOL lol = NO;
- (BOOL) getOTRSessionStatus : (FGOChatViewController *) controller
{
	return (lol = !lol);
}

@end
