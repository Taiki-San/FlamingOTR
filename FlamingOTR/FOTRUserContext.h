//
//  FOTRUserContext.h
//  FlamingOTR
//
//  Created by Taiki on 13/08/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include "libotr.h"

@interface FOTRUserContext : NSObject
{
	BOOL isInitialized, hasPrivateKey;
}

@property (nonatomic) OtrlUserState OTRState;
@property (nonatomic) NSString * accountID;

- (instancetype) initWithAccount : (NSString *) account;

- (BOOL) loadContext;
- (void) triggerFingerprintSync;

@end
