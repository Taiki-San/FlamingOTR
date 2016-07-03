//
//  FlamingOTRSession.m
//  FlamingOTR
//
//  Created by Taiki on 02/07/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@implementation FlamingOTRSession

- (instancetype) initWithController : (FGOChatViewController *) controller
{
	self = [self init];
	
	if(self != nil)
	{
		viewController = controller;
	}
	
	return self;
}

+ (NSString *) buddyUsernameForController : (FGOChatViewController *) controller
{
	return controller.handleName.name;
}

- (NSString *) buddyUsername
{
	return viewController.handleName.name;
}

#pragma mark - Core features

- (void) sendString : (NSString *) string withAccount : (FGOAccount *) account
{
	[[classWithName("FGOIMServiceConnection") sharedInstance] sendMessage:[classWithName("FGOIMServiceMessage")
																		   messageWithBody:string
																		   toHandleWithName:viewController.handleName.name
																		   withState:0]
															  fromAccount:account];
}

- (void) writeString : (NSString *) string
{
	if (![NSThread isMainThread])
	{
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self writeString:string];
		});
	}
	else
	{
		[viewController.conversation insertChatMessageWithEntityName:@"FGOChatMessage"
													  string:string
														sent:YES
												  handleName:viewController.handleName];
		
		[viewController showMessages:@[viewController.conversation.lastMessage]];
	}
}

#pragma mark - Properties

- (BOOL) isOnline
{
	return viewController.presence.isOnline;
}

- (void) setSecure:(BOOL)secure
{
	if(_secure != secure)
	{
		_secure = secure;
		_changeSecureState = NO;
		
		if(![NSThread isMainThread])
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				self.button.locked = secure;
			});
		}
		else
			_button.locked = _secure;
	}
}

@end
