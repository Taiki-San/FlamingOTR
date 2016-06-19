//
//  XMPPFacebookOwnMessage.h
//  XMPPFramework
//
//  Created by Indragie Karunaratne on 7/1/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

// Module to support Facebook's unofficial 'own-message' IQs
@interface XMPPFacebookOwnMessage : XMPPModule
@end

@protocol XMPPFacebookOwnMessageDelegate <NSObject>
/*
 * Called when XMPPFacebookOwnMessage receives an IQ stanza from Facebook indicating that
 * a message was sent to someone via a different Facebook client.
 */
- (void)xmppFacebookOwnMessage:(XMPPFacebookOwnMessage *)ownMessage receivedSentMessage:(XMPPMessage *)sentMessage;
@end