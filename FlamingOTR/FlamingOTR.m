//
//  FlamingOTR.m
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include <pthread/pthread.h>

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

#pragma mark - Session tools

- (FlamingOTRAccount *) getContextForAccount : (FGOAccount *) account
{
	NSString * signature = [FlamingOTRAccount signatureForAccount:account];
	
	FlamingOTRAccount * output = [sessionController objectForKey:signature];
	
	if(output == nil)
	{
		output = [[FlamingOTRAccount alloc] initWithAccount:account];

		if(output != nil)
		{
			[sessionController setObject:output forKey:signature];
		}
	}
	
	return output;
}

- (FlamingOTRAccount *) getContextForSignature : (NSString *) signature
{
	return [sessionController objectForKey:signature];
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

@end
