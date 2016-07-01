//
//  FlamingOTRAccount.m
//  FlamingOTR
//
//  Created by Taiki on 01/07/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@implementation FlamingOTRAccount

@synthesize username = username;

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
		
		OTRJumptable.account_name = account_name;
		OTRJumptable.account_name_free = account_name_free;
	}

	return OTRContext;
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
