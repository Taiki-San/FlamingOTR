//
//  FlamingOTRAccount.m
//  FlamingOTR
//
//  Created by Taiki on 01/07/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@implementation FlamingOTRAccount

@synthesize username = username;
@synthesize realName = realName;
@synthesize OTRContext = OTRContext;

- (instancetype) initWithAccount : (FGOAccount *) _account
{
	self = [self init];
	
	if(self != nil)
	{
		sessions = [NSMutableDictionary dictionary];
		
		account = _account;
		service = account.service;
		
		realName = account.name;
		username = account.sanitizedUsername;
		serverHost = service.serverHost;
		serverPort = service.serverPort;

		[self generateOTRContext];
	}
	
	return self;
}

#pragma mark - OTR

- (void) generateOTRContext
{
	if(OTRContext == NULL)
	{
		OTRContext = [[FOTRUserContext alloc] initWithAccount : self.signature];
	}
}

+ (OtrlMessageAppOps) getJumptable
{
	OtrlMessageAppOps jumptable;
	
	jumptable.policy = get_policy;
	jumptable.create_privkey = create_privkey;
	jumptable.is_logged_in = is_logged_in;
	jumptable.inject_message = inject_message;
	jumptable.update_context_list = NULL;
	jumptable.new_fingerprint = new_fingerprint;
	jumptable.write_fingerprints = write_fingerprints;
	jumptable.gone_secure = gone_secure;
	jumptable.gone_insecure = gone_insecure;
	jumptable.still_secure = NULL;
	jumptable.max_message_size = NULL;
	jumptable.account_name = account_name;
	jumptable.account_name_free = account_name_free;
	jumptable.received_symkey = NULL;
	jumptable.otr_error_message = otr_error_message;
	jumptable.otr_error_message_free = otr_error_message_free;
	jumptable.resent_msg_prefix = NULL;
	jumptable.resent_msg_prefix_free = NULL;
	jumptable.handle_smp_event = handle_smp_event;
	jumptable.handle_msg_event = handle_msg_event;
	jumptable.create_instag = NULL;
	jumptable.convert_msg = NULL;
	jumptable.convert_free = NULL;
	jumptable.timer_control = timer_control;
	
	return jumptable;
}

- (void) triggerFingerprintSync
{
	[OTRContext triggerFingerprintSync];
}

#pragma mark - Context management

- (FlamingOTRSession *) sessionWithController : (FGOChatViewController *) viewController
{
	FlamingOTRSession * output = nil;
	NSString * buddyUsername = [FlamingOTRSession buddyUsernameForController:viewController];
	
	if(buddyUsername != nil)
	{
		output = [sessions objectForKey:buddyUsername];
		if(output == nil)
		{
			output = [[FlamingOTRSession alloc] initWithController:viewController];
			if(output != nil)
			{
				output.account = self;
				[sessions setObject:output forKey:output.buddyUsername];
			}
		}
	}
	
	return output;
}

- (FlamingOTRSession *) sessionWithUsername : (NSString *) buddyUsername
{
	return [sessions objectForKey:buddyUsername];
}

#pragma mark - Utils

+ (FGOAccount *) accountFromCVC : (FGOChatViewController *) controller
{
	return controller.handleName.account;
}

- (NSString *) signature
{
	if(cachedSignature == nil)
	{
		cachedSignature = [NSString stringWithFormat:@"%@ %@ %@", username, serverHost, serverPort];
	}
	
	return cachedSignature;
}

+ (NSString *) signatureForAccount : (FGOAccount *) account
{
	NSString * output;
	
	if(account != nil)
	{
		FGOMessagingService * service = account.service;
		
		output = [NSString stringWithFormat:@"%@ %@ %@", account.sanitizedUsername, service.serverHost, service.serverPort];
	}
	else
		output = nil;
	
	return output;
}

- (void) sendString : (NSString *) string toSession : (FlamingOTRSession *) session
{
	[session sendString:string withAccount:account];
}

- (void) sendString : (NSString *) string toRecipient : (NSString *) recipient
{
	FlamingOTRSession * session = [self sessionWithUsername:recipient];
	
	if(recipient != nil && session != nil)
		[session sendString:string withAccount:account];
}

#pragma mark - LibOTR work

- (NSString *) encryptMessage : (NSString *) message withSession : (FlamingOTRSession *) session
{
	OtrlMessageAppOps jumptable = [[self class] getJumptable];
	gcry_error_t err;
	char *newMessage = NULL;
	
	err = otrl_message_sending(self.OTRContext.OTRState, &jumptable, (__bridge void *) self, self.signature.UTF8String, DEFAULT_PROTOCOL,
							   session.buddyUsername.UTF8String, OTRL_INSTAG_BEST, message.UTF8String, NULL,
							   &newMessage, OTRL_FRAGMENT_SEND_SKIP, NULL, NULL, NULL);
	
	//If for some reason, there is nothing to send, then send nothing
	if(newMessage == NULL)
		return NULL;

	//So, we have a message but there is an error
	if(err != gcry_error(GPG_ERR_NO_ERROR))
	{
		NSLog(@"There was an error while encrypting a message: %s", gcry_strerror(err));
	}
	
	NSString * output = [NSString stringWithUTF8String:newMessage];
	
	otrl_message_free(newMessage);
	
	return output;
}

- (NSString *) decryptMessage : (NSString *) message withSession : (FlamingOTRSession *) session
{
	OtrlMessageAppOps jumptable = [[self class] getJumptable];
	char *newMessage = NULL;
	
	bool ignoreMessage = otrl_message_receiving(self.OTRContext.OTRState, &jumptable, (__bridge void *) self, self.signature.UTF8String, DEFAULT_PROTOCOL, session.buddyUsername.UTF8String, message.UTF8String, &newMessage, NULL, NULL, NULL, NULL);
	
	NSString * output = nil;
	
	//Not a service message
	if(!ignoreMessage)
	{
		if(newMessage != NULL)
		{
			output = [NSString stringWithUTF8String:newMessage];
			otrl_message_free(newMessage);
		}
		else
			output = message;
	}
	
	return output;
}

@end
