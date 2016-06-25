//
//  FlamingOTR.h
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@interface FlamingOTR : NSObject

+ (instancetype) getShared;

- (void) sendString : (NSString *) string toHandle : (FGORosterHandleName *) handle;
- (void) writeString : (NSString *) string toHandle : (FGOChatViewController *) handle;

- (NSNumber *) getNewTokenForConversation : (FGOChatViewController *) conversation;
- (BOOL) isToken : (NSNumber *) token validForConversation : (FGOChatViewController *) conversation;

@end

@interface FlamingOTR (OTRHub) <OTRHub>

@end

@interface FlamingOTR (HighLibOTR)

- (void) initiateOTRSession : (FGOChatViewController *) controller;
- (void) killOTRSession : (FGOChatViewController *) controller;
- (BOOL) getOTRSessionStatus : (FGOChatViewController *) controller;

@end
