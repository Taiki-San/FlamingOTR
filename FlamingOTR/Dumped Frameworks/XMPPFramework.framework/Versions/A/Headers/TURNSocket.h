#import <Foundation/Foundation.h>

@class XMPPIQ;
@class XMPPJID;
@class XMPPStream;
@class GCDAsyncSocket;
@class PortMapper;

/**
 * TURNSocket is an implementation of XEP-0065: SOCKS5 Bytestreams.
 *
 * It is used for establishing an out-of-band bytestream between any two XMPP users,
 * mainly for the purpose of file transfer.
**/
@interface TURNSocket : NSObject
{
	int state;
	BOOL isClient;
	BOOL isDirect;
	
	dispatch_queue_t turnQueue;
	void *turnQueueTag;
	
	XMPPStream *xmppStream;
	XMPPJID *jid;
	NSString *uuid;
	NSString *sid;
	
	id delegate;
	dispatch_queue_t delegateQueue;
	
	dispatch_source_t turnTimer;
	
	NSString *discoUUID;
	dispatch_source_t discoTimer;
	
	NSArray *proxyCandidates;
	NSUInteger proxyCandidateIndex;
	
	NSMutableArray *candidateJIDs;
	NSUInteger candidateJIDIndex;
	
	NSMutableArray *streamhosts;
	NSUInteger streamhostIndex;
	
	XMPPJID *proxyJID;
	PortMapper *portMapper;
	NSString *proxyHost;
	UInt16 proxyPort;
	
	GCDAsyncSocket *asyncSocket;
	
	NSDate *startTime, *finishTime;
}

+ (BOOL)isNewStartTURNRequest:(XMPPIQ *)iq;

+ (NSArray *)proxyCandidates;
+ (void)setProxyCandidates:(NSArray *)candidates;

- (id)initWithStream:(XMPPStream *)stream
			   toJID:(XMPPJID *)aJid
		   elementID:(NSString *)elementID
				 sid:(NSString *)aSid
	directConnection:(BOOL)direct;

- (id)initWithStream:(XMPPStream *)stream incomingTURNRequest:(XMPPIQ *)iq;

- (void)startWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)aDelegateQueue;

- (BOOL)isClient;

- (void)abort;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TURNSocketDelegate
@optional

- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket;

- (void)turnSocketDidFail:(TURNSocket *)sender;

@end