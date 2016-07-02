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
	
	NSString * realName;
	NSString * username;
	NSString * serverHost;
	NSNumber * serverPort;
	
	NSString * cachedSignature;
	
	UserContext * OTRContext;
	
	NSMutableDictionary * sessions;
}

@property (atomic, readonly) NSString * username;
@property (atomic, readonly) NSString * realName;
@property (atomic, readonly) UserContext* OTRContext;

@property (atomic) BOOL shouldResetTimer;
@property (atomic) BOOL hasTimer;

- (instancetype) initWithAccount : (FGOAccount *) account;
+ (FGOAccount *) accountFromCVC : (FGOChatViewController *) controller;

+ (OtrlMessageAppOps) getJumptable;

- (void) triggerFingerprintSync;

- (FlamingOTRSession *) sessionWithController : (FGOChatViewController *) viewController;
- (FlamingOTRSession *) sessionWithUsername : (NSString *) buddyUsername;

- (NSString *) signature;
+ (NSString *) signatureForAccount : (FGOAccount *) account;
+ (NSString *) signatureFromMessageTo : (FGOIMServiceMessage *) message andClient: (id <FGOIMServiceClient>) client;

- (void) sendString : (NSString *) string toSession : (FlamingOTRSession *) session;
- (void) sendString : (NSString *) string toRecipient : (NSString *) recipient;

- (NSString *) encryptMessage : (NSString *) message withSession : (FlamingOTRSession *) session;
- (NSString *) decryptMessage : (NSString *) message withSession : (FlamingOTRSession *) session;

@end
