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

- (id) fgoIMServiceConnection_sendMessage:(id)arg1 fromAccount:(id)arg2;
- (void)fgoIMServiceConnection_client:(id)arg1 didReceiveMessage:(id)arg2;

- (id) nukeHockeyManager;

@end
