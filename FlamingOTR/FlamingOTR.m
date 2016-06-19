//
//  FlamingOTR.m
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include <objc/runtime.h>
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

#pragma mark - Core OTR module

- (void) initiateOTRSession : (FGOChatViewController *) controller
{
	[[classWithName("FGOIMServiceConnection") sharedInstance] sendMessage:[classWithName("FGOIMServiceMessage")
																		   messageWithBody:@"lololololol"
																		   toHandleWithName:controller.handleName.name
																		   withState:0]
															  fromAccount:controller.handleName.account];
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

#pragma mark - Swizzling module

//Implementation based on the excellent blog post available at http://nshipster.com/method-swizzling/

+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector
{
	[self swizzleClass:class originalMethod:originalSelector withMethod:swizzledSelector fromClass:class];
}

+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector fromClass : (Class) injectionClass
{
	Method originalMethod = class_getInstanceMethod(class, originalSelector);
	Method swizzledMethod = class_getInstanceMethod(injectionClass, swizzledSelector);
	
	if(originalMethod != NULL && swizzledMethod != NULL)
	{
		BOOL didAddMethod = class_addMethod(class,
											swizzledSelector,
											method_getImplementation(originalMethod),
											method_getTypeEncoding(originalMethod));
		
		if (didAddMethod)
		{
			class_replaceMethod(class,
								originalSelector,
								method_getImplementation(swizzledMethod),
								method_getTypeEncoding(swizzledMethod));
		}
		else
		{
			method_exchangeImplementations(originalMethod, swizzledMethod);
		}
	}
	else
	{
		if(originalMethod != NULL)
			NSLog(@"Couldn't find %@ in %@", NSStringFromSelector(swizzledSelector), NSStringFromClass(injectionClass));

		else if(swizzledMethod != NULL)
			NSLog(@"Couldn't find %@ in %@", NSStringFromSelector(originalSelector), NSStringFromClass(class));
		
		else
			NSLog(@"Couldn't find either %@ or %@ in %@", NSStringFromSelector(originalSelector), NSStringFromSelector(swizzledSelector), NSStringFromClass(class));
	}
}

+ (void) addSelector : (SEL) selector ofClass : (Class) originalClass toClass : (Class) targetClass
{
	Method method = class_getInstanceMethod(originalClass, selector);
	Method previousHit = class_getInstanceMethod(targetClass, selector);
	
	if(method == NULL)
	{
		NSLog(@"Couldn't locate the method to inject");
	}
	else if(previousHit != NULL)
	{
		NSLog(@"Selector %@ already exist in class %@ (inserting from %@)", NSStringFromSelector(selector), NSStringFromClass(targetClass), NSStringFromClass(originalClass));
	}
	else
	{
		class_addMethod(targetClass,
						selector,
						method_getImplementation(method),
						method_getTypeEncoding(method));
	}
}

@end
