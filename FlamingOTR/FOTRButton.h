//
//  FOTRButton.h
//  FlamingOTR
//
//  Created by Taiki on 19/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@protocol OTRHub <NSObject>

- (void) needActivateOTRForConversation : (id) conversation;
- (void) needDisableOTRForConversation : (id) conversation;
- (void) needRefreshOTRForConversation : (id) conversation;

- (void) needValidateOTRForConversation : (id) conversation withOption : (byte) option;

- (void) showDetailsOfOTRForConversation : (id) conversation;

@end

@interface FOTRButton : NSButton

@property (nonatomic) BOOL locked;
@property (atomic) id<OTRHub> coreListener;		//The object responsible to handle the OTR context

- (instancetype) initButton;

@end
