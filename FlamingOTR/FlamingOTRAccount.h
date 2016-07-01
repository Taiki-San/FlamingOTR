//
//  FlamingOTRAccount.h
//  FlamingOTR
//
//  Created by Taiki on 01/07/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@interface FlamingOTRAccount : NSObject
{
	FGOAccount * account;
	FGORosterHandleName * handleName;
	FGOMessagingService * service;
	
	NSString * username;
	NSString * serverHost;
	NSNumber * serverPort;
	
	NSString * cachedSignature;
	
	UserContext * OTRContext;
	OtrlMessageAppOps OTRJumptable;
}

@property (atomic, readonly) NSString * username;

- (instancetype) initWithAccount : (FGOAccount *) account;
+ (FGOAccount *) accountFromCVC : (FGOChatViewController *) controller;

- (NSString *) signature;
+ (NSString *) signatureForAccount : (FGOAccount *) account;

@end
