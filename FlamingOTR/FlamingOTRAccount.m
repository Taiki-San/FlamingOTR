//
//  FlamingOTRAccount.m
//  FlamingOTR
//
//  Created by Taiki on 01/07/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@implementation FlamingOTRAccount

@synthesize username = username;
@synthesize OTRJumptable = OTRJumptable;
@synthesize OTRContext = OTRContext;

- (instancetype) initWithAccount : (FGOAccount *) _account
{
	self = [self init];
	
	if(self != nil)
	{
		account = _account;
		service = account.service;
		
		username = account.sanitizedUsername;
		serverHost = service.serverHost;
		serverPort = service.serverPort;
	}
	
	return self;
}

#pragma mark - OTR

- (UserContext *) getOTRContext
{
	if(OTRContext == nil)
	{
		OTRContext = [[UserContext alloc] initWithAccount : self.signature];

		OTRJumptable = [[self class] getJumptable];
	}

	return OTRContext;
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
	jumptable.otr_error_message_free = jumptable.otr_error_message_free;
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

@end
