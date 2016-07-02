//
//  FlamingOTR.h
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#define DEFAULT_PROTOCOL "xmpp"

@interface FlamingOTR : NSObject
{
	BOOL initialized;
}

+ (nonnull instancetype) getShared;

- (nullable FlamingOTRAccount *) getContextForAccount : (nonnull FGOAccount *) account;
- (nullable FlamingOTRAccount *) getContextForSignature : (nonnull NSString *) signature;

@end

@interface FlamingOTR (OTRHub) <OTRHub>

@end

@interface FlamingOTR (HighLibOTR)

- (void) initiateOTRSession : (nonnull FGOChatViewController *) controller fromButton: (nonnull FOTRButton *) button;
- (void) initiateOTRSession:(nonnull FlamingOTRSession *) session;
- (void) killOTRSession : (nonnull FlamingOTRSession *) controller;
- (void) reloadOTRSession : (nonnull FlamingOTRSession *) controller;

@end
