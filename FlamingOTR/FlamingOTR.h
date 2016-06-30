//
//  FlamingOTR.h
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@interface FlamingOTR : NSObject
{
	BOOL initialized;
}

+ (nonnull instancetype) getShared;

- (void) sendString : (nonnull NSString *) string toHandle : (nonnull FGORosterHandleName *) handle;
- (void) writeString : (nonnull NSString *) string toHandle : (nonnull FGOChatViewController *) handle;

- (nonnull NSNumber *) getNewTokenForConversation : (nonnull FGOChatViewController *) conversation;
- (BOOL) isToken : (nonnull NSNumber *) token validForConversation : (nonnull FGOChatViewController *) conversation;

@end

@interface FlamingOTR (OTRHub) <OTRHub>

@end

@interface FlamingOTR (HighLibOTR)

- (void) initiateOTRSession : (nonnull FGOChatViewController *) controller;
- (void) killOTRSession : (nonnull FGOChatViewController *) controller;
- (BOOL) getOTRSessionStatus : (nonnull FGOChatViewController *) controller;

@end
