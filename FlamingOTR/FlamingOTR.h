//
//  FlamingOTR.h
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlamingOTR : NSObject <OTRHub>

+ (instancetype) getShared;

- (void) sendString : (NSString *) string toHandle : (FGORosterHandleName *) handle;
- (void) writeString : (NSString *) string toHandle : (FGOChatViewController *) handle;

- (void) initiateOTRSession : (FGOChatViewController *) controller;
- (void) killOTRSession : (FGOChatViewController *) controller;
- (BOOL) getOTRSessionStatus : (FGOChatViewController *) controller;

+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector;
+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector fromClass : (Class) injectionClass;

+ (void) addSelector : (SEL) selector ofClass : (Class) originalClass toClass : (Class) targetClass;

@end
