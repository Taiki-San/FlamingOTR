//
//  FlamingHook.m
//  FlamingOTR
//
//  Created by Taiki on 10/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include <objc/runtime.h>

@implementation FlamingHook

//Hook FGOChatViewController

- (void) fgochatviewcontroller_loadView
{
	FGOChatViewController * controller = (id) self;

	//We remove the OTR status messages
	NSMutableIndexSet * indexSet = [NSMutableIndexSet new];
	
	[controller.messages enumerateObjectsUsingBlock:^(FGOPresenceChatMessage * message, NSUInteger idx, BOOL * stop)
	{
		if([[message className] isEqualToString:@"FGOPresenceChatMessage"] && message.statusType.intValue == PCODE_OTR)
		{
			[indexSet addIndex:idx];
		}
	}];

	if([indexSet count] > 0)
	{
		NSMutableArray * mutableMessages = controller.messages.mutableCopy;
		[mutableMessages removeObjectsAtIndexes:indexSet];
		controller.messages = [NSArray arrayWithArray:mutableMessages];
	}
	
	//Standard initialization
	[self fgochatviewcontroller_loadView];
	
	//Generate a session and an account so the preprocessing can start right now
	FlamingOTRSession * session = [[[FlamingOTR getShared] getContextForAccount:[FlamingOTRAccount accountFromCVC:controller]] sessionWithController:controller];
	
	if(session != nil)
	{
		//We insert the OTR control button
		FOTRButton * button = [[FOTRButton alloc] initButtonWithController:controller];
		if(button != nil)
		{
			button.coreListener = [FlamingOTR getShared];
			[controller.titleBarView addSubview:button];		//The button position is auto set as it already has to handle the container frame changes
		}
		
		session.button = button;
	}
	
	[[FlamingOTR getShared] registerSession:session withTableView:controller.tableView];
}

//Hook FGOChatPresenceTableCellView
- (void) FGOChatPresenceTableCellView_viewDidMoveToWindow
{
	[self FGOChatPresenceTableCellView_viewDidMoveToWindow];
	
	FGOChatPresenceTableCellView * view = (id) self;
	__block FGOChatLineImageView * image = nil;
	__block FlamingOTRSession * session;
 
	//First, we need to find our tableview to recover the session
	NSView * superview = view.superview;
	while (superview != nil && ![[superview className] isEqualToString:@"FGOChatTableView"])
		superview = superview.superview;
	
	session = [[FlamingOTR getShared] sessionFromTableview:(id) superview];
	
	[view.subviews enumerateObjectsUsingBlock:^(NSView * obj, NSUInteger idx, BOOL * stop) {

		if([[obj className] isEqualToString:@"BTRImageView"])
			image = (id) obj;
		
		else if([obj isKindOfClass:[NSTextField class]])
		{
			NSTextField * textField = (id) obj;
			NSString * messageHTML = textField.attributedStringValue.mn_HTMLRepresentationFromCoreTextAttributes;
			
			if([messageHTML containsString:@"went  at"])	//PCODE_OTR
			{
				NSImage * image2 = [NSImage imageNamed:@"chat-otr-status-icon"];
				if(image2)
					image.image = image2;
				
				//The next OTR status message we have to write
				messageHTML = [session pollNextOTRMessage];
				if(messageHTML == nil)	//Default message
				{
					messageHTML = @"<p><span style='font: bold 11px \"Helvetica Neue\"; -cocoa-font-postscriptname: \"HelveticaNeue-Bold\"; '>OTR Status:</span><span style='font: 11px \"Helvetica Neue\"; -cocoa-font-postscriptname: \"HelveticaNeue\"; '> Old OTR status, should've been discarded</span></p>";
				}
				
				textField.attributedStringValue = [[NSAttributedString alloc] mn_initWithHTMLString:messageHTML];
			}
			
			*stop = YES;
		}
	}];
}

//Hook FGOIMServiceConnection
- (id) fgoIMServiceConnection_sendMessage:(FGOIMServiceMessage *) message fromAccount: (FGOAccount *) _account
{
	if(message.body != nil && ![message.body hasPrefix:@OTR_HEADER])	//We don't want to process already OTRed strings
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
	
#ifdef LOG_EVERYTHING
	if(message.body != nil)
		NSLog(@"Sending: %@ from %@ to %@", message.body, [[FlamingOTR getShared] getContextForAccount:_account].username, message.to.name);
#endif
	
	return [self fgoIMServiceConnection_sendMessage:message fromAccount:_account];
}

- (void)fgoIMServiceConnection_client:(id <FGOIMServiceClient>) client didReceiveMessage:(FGOIMServiceMessage *) message
{
	if(message.body != nil)
	{
		if([message.body hasPrefix:@OTR_HEADER])
		{
			FlamingOTRAccount * account = [[FlamingOTR getShared] getContextForAccount:[(FGOIMServiceConnection *) client.delegate accountForClient:client]];
			
			FlamingOTRSession * session = [account sessionWithUsername:message.from.name];
			if(session == nil)
			{
				//Okay, the ChatViewController doesn't exist.
				//We'll look if there is a known FGOConversation for this contact
				NSString * goal = message.from.name;
				FGOChatListViewController * chatListViewController = ((FGOAppDelegate *) NSApp.delegate).mainWindowController.chatListViewController;
				__block FGOChatConversation * conversation = nil;

				[chatListViewController.conversations enumerateObjectsUsingBlock:^(FGOChatConversation * obj, NSUInteger idx, BOOL * stop) {

					//FGOChatConversation sadly doesn't contain the email address we need
					//However, by digging significantly, we could find it, in a NSSet
					//Our sample only showed one hit but who knows
					
					[[obj.handle.handleNames allObjects] enumerateObjectsUsingBlock:^(FGORosterHandleName * obj2, NSUInteger idx2, BOOL * stop2) {

						if([obj2.sanitizedName isEqualToString:goal])
						{
							conversation = obj;
							*stop2 = YES;
						}
					}];
					
					if(conversation != nil)
						*stop = YES;
				}];
				
				if(conversation != nil)
				{
					FGOChatViewController * controller = [chatListViewController chatViewControllerForConversation:conversation createIfNeeded:YES];
					
					//If the ChatViewController was just created, we must push it to the screen for it to populate
					if([FlamingOTRSession buddyUsernameForController:controller] == nil)
					{
						[chatListViewController displayConversationViewController:controller displayType:1];
					}
					
					session = [account sessionWithController:controller];
				}
				
				if(session == nil)
				{
					//Ok, this contact isn't in the list of recent contact
					//We'll send a fake message, wait for the UI to update
					
					FGOIMServiceMessage * copyMessage = [message copy];
					FGOIMServiceConnection * copySelf = (id) self;
					
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
						
						[copySelf client:client didReceiveMessage:copyMessage];
					});
					
					message.body = @"[OTR Service message: Initiating secure chat]";
				}
			}

			if(session != nil)
			{
				NSString * decryptedMessage = [account decryptMessage:message.body withSession:session];
				
				if(decryptedMessage != nil)
				{
					message.body = message.HTMLBody = decryptedMessage;
					message.attributedContents = [[NSAttributedString alloc] mn_initWithHTMLString:message.HTMLBody];
				}
				
				//Service message, to be discarded
				else
					return;
			}
		}
		
#ifdef LOG_EVERYTHING
		NSLog(@"Received: %@ to %@ from %@", message.body, message.to.name, message.from.name);
#endif
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
