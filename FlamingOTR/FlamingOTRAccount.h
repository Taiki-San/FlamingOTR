//
//  FlamingOTRAccount.h
//  FlamingOTR
//
//  Created by Taiki on 01/07/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include "FOTRUserContext.h"

@interface FlamingOTRAccount : NSObject
{
	FGOAccount * account;
	FGORosterHandleName * handleName;
	FGOMessagingService * service;
	
	NSString * realName;
	NSString * username;
	NSString * serverHost;
	NSNumber * serverPort;
	
	NSString * cachedSignature;
	
	FOTRUserContext * OTRContext;
	
	NSMutableDictionary * sessions;
}

@property (atomic, readonly) NSString * username;
@property (atomic, readonly) NSString * realName;
@property (atomic, readonly) FOTRUserContext* OTRContext;

@property (atomic) BOOL shouldResetTimer;
@property (atomic) BOOL hasTimer;

- (instancetype) initWithAccount : (FGOAccount *) account;
+ (FGOAccount *) accountFromCVC : (FGOChatViewController *) controller;

- (void) generateOTRContext;
+ (OtrlMessageAppOps) getJumptable;

- (void) triggerFingerprintSync;

- (FlamingOTRSession *) sessionWithController : (FGOChatViewController *) viewController;
- (FlamingOTRSession *) sessionWithUsername : (NSString *) buddyUsername;

- (NSString *) signature;
+ (NSString *) signatureForAccount : (FGOAccount *) account;

- (void) sendString : (NSString *) string toSession : (FlamingOTRSession *) session;
- (void) sendString : (NSString *) string toRecipient : (NSString *) recipient;

- (NSString *) encryptMessage : (NSString *) message withSession : (FlamingOTRSession *) session;
- (NSString *) decryptMessage : (NSString *) message withSession : (FlamingOTRSession *) session;

@end
