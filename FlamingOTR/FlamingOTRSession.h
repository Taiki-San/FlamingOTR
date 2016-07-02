//
//  FlamingOTRSession.h
//  FlamingOTR
//
//  Created by Taiki on 02/07/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@class FlamingOTRAccount;

@interface FlamingOTRSession : NSObject
{
	FGOChatViewController * viewController;
}

@property (nonatomic, getter=isSecure) BOOL secure;
@property (atomic) FOTRButton * button;
@property (atomic, getter=isChangingSecureState) BOOL changeSecureState;

@property (nonatomic) FlamingOTRAccount * account;

- (instancetype) initWithController : (FGOChatViewController *) controller;

+ (NSString *) buddyUsernameForController : (FGOChatViewController *) controller;
- (NSString *) buddyUsername;

- (void) sendString : (NSString *) string withAccount : (FGOAccount *) account;
- (void) writeString : (NSString *) string;

- (BOOL) isOnline;

@end
