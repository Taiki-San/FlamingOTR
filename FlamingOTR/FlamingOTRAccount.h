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
@property (atomic, readonly) OtrlMessageAppOps OTRJumptable;
@property (atomic, readonly) UserContext* OTRContext;

@property (atomic) BOOL shouldResetTimer;
@property (atomic) BOOL hasTimer;

@property (atomic, getter=isSecure) BOOL secure;

- (instancetype) initWithAccount : (FGOAccount *) account;
+ (FGOAccount *) accountFromCVC : (FGOChatViewController *) controller;

+ (OtrlMessageAppOps) getJumptable;

- (void) triggerFingerprintSync;

- (NSString *) signature;
+ (NSString *) signatureForAccount : (FGOAccount *) account;

@end
