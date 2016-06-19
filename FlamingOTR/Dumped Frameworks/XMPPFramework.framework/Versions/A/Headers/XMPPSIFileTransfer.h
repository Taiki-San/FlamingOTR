//
//  XMPPSIFileTransfer.h
//  XMPPFramework
//
//  Created by Indragie Karunaratne on 2013-02-05.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "XMPP.h"

extern NSString* const XMLNSJabberSI; // @"http://jabber.org/protocol/si"
extern NSString* const XMLNSJabberSIFileTransfer; // @"http://jabber.org/protocol/si/profile/file-transfer"

extern NSString* const XMPPSIProfileSOCKS5Transfer; // @"http://jabber.org/protocol/bytestreams"
extern NSString* const XMPPSIProfileIBBTransfer; // @"http://jabber.org/protocol/ibb"

@class XMPPSITransfer;
/*
 * Implementation of XEP-0095 Stream Initiation for initiating a data stream between
 * two XMPP entities, and XEP-0096, which uses stream initiation for the purpose of
 * file transfer.
 */
@interface XMPPSIFileTransfer : XMPPModule

#pragma mark - Sending

/*
 * Sends an IQ get request to the given JID with an <si> element containing information
 * about the file being transferred, as well as the available stream methods to transfer
 * the file data. 
 *
 * name - The name of the file (required)
 * size - The file size in bytes (required)
 * description - An extended description of the file (optional)
 * mimeType - The MIME type of the file (optional)
 * hash - The MD5 hash of the file (optional)
 * lastModifiedDate - The date when the file was last modified (optional)
 * streamMethods - Array of stream methods that the file transfer will support. SUPPORTED VALUES:
 *		http://jabber.org/protocol/bytestreams - SOCKS5 Bytestream (XEP-0065)
 *		http://jabber.org/protocol/ibb - In Band Bytestream (XEP-0047)
 * jid - The target JID to send the offer to
 * 
 * Returns an XMPPSITransfer object representing this stream initiation offer.
 */
- (XMPPSITransfer *)sendStreamInitiationOfferForFileURL:(NSURL *)URL
											description:(NSString *)description
										  streamMethods:(NSArray *)methods
												  toJID:(XMPPJID *)jid
												  error:(NSError **)error;

/*
 * Convenience method for sending a stream initiation offer for the most common use case
 * Fills in the hash & size automatically, and passes the default stream methods supported by 
 * this class (XMPPSIProfileSOCKS5Transfer and XMPPSIProfileIBBTransfer).
 *
 * Returns an XMPPSITransfer object representing this stream initiation offer.
 */
- (XMPPSITransfer *)sendStreamInitiationOfferForFileURL:(NSURL *)URL
												  toJID:(XMPPJID *)jid
												  error:(NSError **)error;

#pragma mark - Receiving
/*
 Accepts the specified stream initiation offer
 */
- (void)acceptStreamInitiationOfferForTransfer:(XMPPSITransfer *)transfer;

/*
 Rejects the specified stream initiation offer
 */
- (void)rejectOfferForTransfer:(XMPPSITransfer *)transfer;
@end

@protocol XMPPSIFileTransferDelegate <NSObject>
@optional
/*
 * Called when another XMPP entity sends a stream initiation offer for a file transfer
 */
- (void)xmppSIFileTransfer:(XMPPSIFileTransfer *)fileTransfer receivedOfferForTransfer:(XMPPSITransfer *)transfer;

/*
 * Called when the XMPP stream has successfully sent a stream initiation offer
 */
- (void)xmppSIFileTransfer:(XMPPSIFileTransfer *)fileTransfer didSendOfferForTransfer:(XMPPSITransfer *)transfer;

/*
 * Called when either an outgoing or incoming file transfer begins
 */
- (void)xmppSIFileTransfer:(XMPPSIFileTransfer *)fileTransfer transferDidBegin:(XMPPSITransfer *)transfer;

/*
 * Called when a file transfer completes. (If this is an incoming transfer, this means
 * that you can now access the data property to retrieve the downloaded file data).
 */
- (void)xmppSIFileTransfer:(XMPPSIFileTransfer *)fileTransfer transferDidEnd:(XMPPSITransfer *)transfer;

/*
 * Called when the specified file transfer fails with error information if available
 */
- (void)xmppSIFileTransfer:(XMPPSIFileTransfer *)fileTransfer tranferFailed:(XMPPSITransfer *)transfer withError:(NSError *)error;

/*
 * Called to inform the delegate of the progress of the file transfer operation. The totalBytes
 * and transferredBytes properties of XMPPTransfer (which are also KVO observable) can be used
 * to determine the percentage completion of the transfer).
 */
- (void)xmppSIFileTransfer:(XMPPSIFileTransfer *)fileTransfer transferUpdatedProgress:(XMPPSITransfer *)transfer;
@end

/*
 * Class that represents an XMPP file transfer via XMPPSIFileTransfer
 */
@interface XMPPSITransfer : NSObject
/*
 * The stream transfer method being used to transfer the file
 */
@property (nonatomic, copy, readonly) NSString *streamMethod;
/*
 * The remote JID that the transfer is with
 */
@property (nonatomic, strong, readonly) XMPPJID *remoteJID;
/*
 * The URL of the file being transferred or received.
 * If this is an outgoing transfer, this will be the URL of the 
 * file being sent (copied to a temporary location)
 * If this is an incoming transfer, it will point to the URL at
 * which the downloaded file can be found after the transfer is complete.
 */
@property (nonatomic, strong, readonly) NSURL *URL;
/*
 * The total number of bytes to transfer. KVO observable.
 */
@property (nonatomic, assign, readonly) unsigned long long totalBytes;
/*
 * The number of bytes already transferred. KVO observable.
 */
@property (nonatomic, assign, readonly) unsigned long long transferredBytes;
/*
 * YES if the transfer is an outgoing transfer, NO if the transfer is an incoming transfer
 */
@property (nonatomic, assign, readonly) BOOL outgoing;
/*
 * The name of the file being transferred
 */
@property (nonatomic, copy, readonly) NSString *fileName;
/*
 * An optional extended description of the file being transferred
 */
@property (nonatomic, copy, readonly) NSString *fileDescription;
/*
 * The MIME type of the file being transferred
 */
@property (nonatomic, copy, readonly) NSString *mimeType;
/*
 * The MD5 hash of the file being transferred
 */
@property (nonatomic, copy, readonly) NSString *MD5Hash;
/*
 * The unique identifier for this file transfer (used as the elementID in incoming and outgoing
 * XMPPIQ stanzas)
 */
@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
/*
 * The SID of the transfer
 */
@property (nonatomic, copy, readonly) NSString *sid;
/*
 * The date the file was last modified, if available
 */
@property (nonatomic, strong, readonly) NSDate *lastModifiedDate;
@end
