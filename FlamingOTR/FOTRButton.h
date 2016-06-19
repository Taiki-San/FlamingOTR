//
//  FOTRButton.h
//  FlamingOTR
//
//  Created by Taiki on 19/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@class FOTRButton;

@protocol OTRHub <NSObject>

- (void) needActivateOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button;
- (void) needDisableOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button;
- (void) needRefreshOTRForConversation : (FGOChatViewController *) conversation fromButton : (FOTRButton *) button;

- (void) needValidateOTRForConversation : (FGOChatViewController *) conversation withOption : (byte) option;

- (void) showDetailsOfOTRForConversation : (FGOChatViewController *) conversation;

@end

@interface FOTRButton : NSButton

@property (nonatomic) BOOL locked;
@property (atomic) id<OTRHub> coreListener;		//The object responsible to handle the OTR context

- (instancetype) initButtonWithController : (FGOChatViewController *) controller;

@end
