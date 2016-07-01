//
//  FlamingOTR.h
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@class UserContext;
@class FlamingOTRAccount;
@class FGOAccount;

@interface FlamingOTR : NSObject
{
	BOOL initialized;
}

+ (nonnull instancetype) getShared;

- (nonnull NSNumber *) getNewTokenForConversation : (nonnull FGOChatViewController *) conversation;
- (BOOL) isToken : (nonnull NSNumber *) token validForConversation : (nonnull FGOChatViewController *) conversation;

- (nullable FlamingOTRAccount *) getContextForAccount : (nonnull FGOAccount *) account;
- (nullable FlamingOTRAccount *) getContextForSignature : (nonnull NSString *) signature;

- (void) sendString : (nonnull NSString *) string toHandle : (nonnull FGORosterHandleName *) handle;
- (void) writeString : (nonnull NSString *) string toHandle : (nonnull FGOChatViewController *) handle;

@end

@interface FlamingOTR (OTRHub) <OTRHub>

@end

@interface FlamingOTR (HighLibOTR)

- (void) initiateOTRSession : (nonnull FGOChatViewController *) controller;
- (void) killOTRSession : (nonnull FGOChatViewController *) controller;
- (BOOL) getOTRSessionStatus : (nonnull FGOChatViewController *) controller;

@end
