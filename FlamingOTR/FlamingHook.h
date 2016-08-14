//
//  FlamingHook.h
//  FlamingOTR
//
//  Created by Taiki on 10/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

Class classWithName(const char * name);

@interface FlamingHook : NSObject

- (void) fgochatviewcontroller_loadView;

- (void) FGOChatPresenceTableCellView_viewDidMoveToWindow;

- (id) fgoIMServiceConnection_sendMessage:(id)arg1 fromAccount:(id)arg2;
- (void)fgoIMServiceConnection_client:(id)arg1 didReceiveMessage:(id)arg2;

- (id) nukeHockeyManager;

+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector;
+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector fromClass : (Class) injectionClass;

+ (void) addSelector : (SEL) selector ofClass : (Class) originalClass toClass : (Class) targetClass;

@end

enum
{
	PCODE_OFFLINE = 0,	//Gray
	PCODE_ONLINE = 1,	//Green
	PCODE_AWAY = 2,		//Red
	PCODE_IDLE = 3,		//Yellowish
	PCODE_IDLE2 = 4,	//Yellowish
	PCODE_WAITING_AUTHORIZATION = 5,	//Gray
	PCODE_OTR = 6		//Patched: Pink \o/
};

