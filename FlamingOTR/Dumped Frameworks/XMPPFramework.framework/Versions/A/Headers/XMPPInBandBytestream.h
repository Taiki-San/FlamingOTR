//
//  XMPPInBandBytestream.h
//  XMPPFramework
//
//  Created by Indragie Karunaratne on 2013-02-11.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

/*
 * Implementation of XEP-0047, which enables two entities to establish 
 * a virtual bytestream over which they can exchange Base64-encoded chunks 
 * of data over XMPP itself
 *
 * This implementation currently does NOT support bidirectional transfer.
 */
@interface XMPPInBandBytestream : NSObject

/*
 * Requests a transfer session with the specified JID
 *
 * The block size represents the amount of data that can be transferred over 1 stanza
 * The elementID is the element ID to use for all communication with this remote peer. 
 * If no elementID is specified, a random one will be generated.
 * This should be the same as anything that was used earlier to negotiate the transfer.
 * 
 * This implementation will default to sending the largest possible block size (65535 bytes)
 * If the receiver requests smaller chunks, the transfer will be adjusted as necessary until
 * it reaches the minimum block size (4KB) at which point the transfer will fail if the responder
 * does not accept it.
 */
- (id)initOutgoingBytestreamWithStream:(XMPPStream *)stream
								 toJID:(XMPPJID *)jid
							 elementID:(NSString *)elementID
								   sid:(NSString *)sid
							   fileURL:(NSURL *)URL
								 error:(NSError **)error;

/*
 * Creates a bytestream for an incoming transfer session.
 *
 * The elementID is the element ID to use for all communication with this remote peer. 
 * Returns nil if iq is not a valid bytestream request stanza
 */
- (id)initIncomingBytestreamRequest:(XMPPIQ *)iq withStream:(XMPPStream *)stream;

/*
 * Start the transfer 
 */
- (void)startWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)aDelegateQueue;

/*
 * The remote JID that the transfer is with
 */
@property (nonatomic, strong, readonly) XMPPJID *remoteJID;

/*
 * The block size being used for the transfer
 */
@property (nonatomic, assign, readonly) NSUInteger blockSize;

/*
 * Whether the transfer is an outgoing transfer
 */
@property (nonatomic, assign, readonly) BOOL outgoing;

/*
 * Element ID for IQ elements used in all communication for this transfer
 */
@property (nonatomic, copy, readonly) NSString *elementID;

/*
 * SID for all IBB related elements
 */
@property (nonatomic, copy, readonly) NSString *sid;
@end

@protocol XMPPInBandBytestreamDelegate <NSObject>
@optional
/*
 * Called when the transfer begins.
 */
- (void)xmppIBBTransferDidBegin:(XMPPInBandBytestream *)stream;

/*
 * Called when data has been written over the bytestream to update progress
 */
- (void)xmppIBBTransfer:(XMPPInBandBytestream *)stream didWriteDataOfLength:(NSUInteger)length;

/*
 * Called when data has been read over the bytestream to update progress
 */
- (void)xmppIBBTransfer:(XMPPInBandBytestream *)stream didReadData:(NSData *)data;

/*
 * Called when the transfer fails. An NSError describing the issue is included where possible
 */
- (void)xmppIBBTransfer:(XMPPInBandBytestream *)stream failedWithError:(NSError *)error;

/*
 * Called when the transfer completes. If this is an incoming transfer, at this point you can
 * retrieve the downloaded data from the data property.
 */
- (void)xmppIBBTransferDidEnd:(XMPPInBandBytestream *)stream;
@end