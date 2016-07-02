//
//  FlamingHook.m
//  FlamingOTR
//
//  Created by Taiki on 10/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#import "FlamingHook.h"
#include <objc/runtime.h>

@implementation FlamingHook

//Hook FGOChatViewController

- (void) fgochatviewcontroller_loadView
{
	[self fgochatviewcontroller_loadView];
	
	//We insert the OTR control button
	FGOChatViewController * controller = (id) self;
	
	FOTRButton * button = [[FOTRButton alloc] initButtonWithController:controller];
	if(button != nil)
	{
		button.coreListener = [FlamingOTR getShared];
		[controller.titleBarView addSubview:button];		//The button position is auto set as it already has to handle the container frame changes
	}
}

//Hook FGOIMServiceConnection
- (id) fgoIMServiceConnection_sendMessage:(FGOIMServiceMessage *) message fromAccount: (FGOAccount *) _account
{
	if(message.body != nil && ![message.body hasPrefix:@"?OTR"])	//We don't want to process already OTRed strings
	{
		FlamingOTRAccount * account = [[FlamingOTR getShared] getContextForAccount:_account];
		FlamingOTRSession * session = [account sessionWithUsername:message.to.name];
		
		//We didn't started an OTR session
		//Ideally, we should find out if we should stricly enforce them and refusing to send the message but meh, later
		if(session == nil)
		{
			//Yef
		}
		
		if(session != nil && session.isSecure)
		{
			NSString * encryptedMessage = [account encryptMessage:message.body withSession:session];
			
			if(encryptedMessage == nil)
				return nil;
			
			message.body = encryptedMessage;
		}
	}
	
	NSLog(@"Sending: %@ from %@ to %@", message.body, message.from.name, message.to.name);
	
	return [self fgoIMServiceConnection_sendMessage:message fromAccount:_account];
}

- (void)fgoIMServiceConnection_client:(id <FGOIMServiceClient>) client didReceiveMessage:(FGOIMServiceMessage *) message
{
	if(message.body != nil)
	{
		if([message.body hasPrefix:@"?OTR"])
		{
			FlamingOTRAccount * account = [[FlamingOTR getShared] getContextForSignature:
										   [FlamingOTRAccount signatureFromMessageTo:message andClient:client]];
			FlamingOTRSession * session = [account sessionWithUsername:message.to.name];
			
			NSString * decryptedMessage = [account decryptMessage:message.body withSession:session];
			
			if(decryptedMessage != nil)
				message.body = decryptedMessage;
			
			//Service message, to be discarded
			else
				return;
		}

		NSLog(@"Received: %@ to %@ from %@", message.body, message.to.name, message.from.name);
	}
	
	[self fgoIMServiceConnection_client:client didReceiveMessage:message];
}


//Nuke Hockey
- (id) nukeHockeyManager	{	return nil;	}

#pragma mark - Swizzle toolkit

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
