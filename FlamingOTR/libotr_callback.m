//
//  libotr_callback.m
//  FlamingOTR
//
//  Created by Taiki on 30/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include "libotr.h"

const char * account_name(void *opdata, const char *_account, const char *protocol)
{
	const char * output = NULL;

	FlamingOTRAccount * account = (__bridge FlamingOTRAccount *)(opdata);
	if(account == nil)
	{
		NSString * signature = [NSString stringWithUTF8String:_account];
		if(signature != nil)
			account = [[FlamingOTR getShared] getContextForSignature:signature];
	}
	
	if(account != nil)
	{
		output = strdup(account.username.UTF8String);
	}
	
	return output;
}

void account_name_free(void *opdata, const char *account_name)
{
	free((void*) account_name);
}

void gone_secure(void *opdata, ConnContext *context)
{
	FlamingOTRAccount * account = (__bridge FlamingOTRAccount *)(opdata);
	FlamingOTRSession * session = [account sessionWithUsername:[NSString stringWithUTF8String:context->username]];
	
	if(session != nil)
		session.secure = YES;
}

/* A ConnContext has left a secure state. */
void gone_insecure (void *opdata, ConnContext *context)
{
	FlamingOTRAccount * account = (__bridge FlamingOTRAccount *)(opdata);
	FlamingOTRSession * session = [account sessionWithUsername:[NSString stringWithUTF8String:context->username]];
	
	if(session != nil)
		session.secure = NO;
}

void create_privkey(void *opdata, const char *accountname, const char *protocol)
{
	NSLog(@"Shouldn't be called!");
}

OtrlPolicy get_policy(void *opdata, ConnContext *context)
{
	return OTRL_POLICY_ALLOW_V3 | OTRL_POLICY_SEND_WHITESPACE_TAG | OTRL_POLICY_WHITESPACE_START_AKE | OTRL_POLICY_ERROR_START_AKE;
}

void inject_message(void *opdata, const char *accountname, const char *protocol, const char *recipient, const char *message)
{
	FlamingOTRAccount * account = (__bridge FlamingOTRAccount *)(opdata);
	if(account != nil)
	{
		NSLog(@"Sending %s to %s", message, recipient);
		[account sendString:[NSString stringWithUTF8String:message] toRecipient:[NSString stringWithUTF8String:recipient]];
	}
}

int is_logged_in(void *opdata, const char *accountname, const char *protocol, const char *recipient)
{
	FlamingOTRAccount * account = (__bridge FlamingOTRAccount *)(opdata);
	FlamingOTRSession * session = [account sessionWithUsername:[NSString stringWithUTF8String:recipient]];
	
	if(session != nil)
		return session.isOnline;

	return -1;
}

void new_fingerprint(void *opdata, OtrlUserState us, const char *accountname, const char *protocol, const char *username, unsigned char fingerprint[20])
{
#warning "Yeah, may be worth notifying the user..."
	NSLog(@"Hum... New fingerprint for user %s (%s)", username, fingerprint);
}

void write_fingerprints(void *opdata)
{
	[(__bridge FlamingOTRAccount *) opdata triggerFingerprintSync];
}

//This function is called from time to time and apparently clean up stall context, which help enforcing forward secrecy
void timer_control(void *opdata, unsigned int interval)
{
	FlamingOTRAccount * account = (__bridge FlamingOTRAccount *) opdata;
	
	//If a timer is already running, we don't interact with it
	if(account.hasTimer)
		return;
	
	//If we get called by otrl_message_poll, we shouldn't just repeat it
	account.shouldResetTimer = NO;

	if(interval != 0)
	{
		account.hasTimer = YES;
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

			account.hasTimer = NO;
			account.shouldResetTimer = YES;
			
			OtrlMessageAppOps jumptable = account.OTRJumptable;
			
			otrl_message_poll(account.OTRContext.OTRState, &jumptable, opdata);
			
			if(account.shouldResetTimer)
				timer_control(opdata, interval);
		});
	}
}

void received_symkey(void *opdata, ConnContext *context, unsigned int use, const unsigned char *usedata, size_t usedatalen, const unsigned char *symkey)
{
	NSLog(@"%s's client requested the use of an alternative symetric key. Probably harmless but could be worth tracing", context->username);
}

const char * otr_error_message(void *opdata, ConnContext *context, OtrlErrorCode err_code)
{
	const char * output;

	switch (err_code)
	{
		case OTRL_ERRCODE_ENCRYPTION_ERROR:
			output = "OTR Failure: Couldn't encrypt a message.";
			break;
			
		case OTRL_ERRCODE_MSG_NOT_IN_PRIVATE:
			output = "Received an unexpected encrypted message. We were missing the keys to be able to read it.";
			break;
			
		case OTRL_ERRCODE_MSG_UNREADABLE:
			output = "Received a message we couldn't decrypt.";
			break;
			
		case OTRL_ERRCODE_MSG_MALFORMED:
			output = "Received a corrupted message.";
			break;
			
		default:
			output = NULL;
			break;
	}
	
	return strdup(output);
}

void otr_error_message_free(void *opdata, const char *err_msg)
{
	free((void*) err_msg);
}

void handle_smp_event(void *opdata, OtrlSMPEvent smp_event, ConnContext *context, unsigned short progress_percent, char *question)
{
#warning "Need implementation"
}

void handle_msg_event(void *opdata, OtrlMessageEvent msg_event, ConnContext *context, const char *message, gcry_error_t err)
{
	switch(msg_event)
	{
		case OTRL_MSGEVENT_ENCRYPTION_REQUIRED:
		{
#warning "Could be worth sending this message"
			NSLog(@"Hum, you're trying to send an unencrypted message but you said you wanted to enforce strictly your privacy with this contact :/");
			break;
		}
			
		case OTRL_MSGEVENT_ENCRYPTION_ERROR:
		{
#warning "Could be worth sending this message"
			NSLog(@"OTR error, maths^W^Wour crypto module is breaking down");
			break;
		}
			
		case OTRL_MSGEVENT_CONNECTION_ENDED:
		{
#warning "Could be worth sending this message"
			NSLog(@"OTR session ended, you should do the same");
			break;
		}
			
		case OTRL_MSGEVENT_SETUP_ERROR:
		{
#warning "Could be worth sending this message"
			NSLog(@"Couldn't set up the encrypted channel, error: %s", gpg_strerror(err));
			break;
		}
			
		case OTRL_MSGEVENT_MSG_REFLECTED:
		{
			NSLog(@"Someone is trying to play funny... We're receiving our own OTR messages...");
			break;
		}
			
		case OTRL_MSGEVENT_MSG_RESENT:
		{
			NSLog(@"Retrying to send a message");
			break;
		}
			
		case OTRL_MSGEVENT_RCVDMSG_NOT_IN_PRIVATE:
		case OTRL_MSGEVENT_RCVDMSG_UNREADABLE:
		case OTRL_MSGEVENT_RCVDMSG_MALFORMED:
		case OTRL_MSGEVENT_RCVDMSG_UNRECOGNIZED:
		{
#warning "Should notify that we received an invalid message"
			NSLog(@"We received some stuffs we couldn't parse :/");
			break;
		}
			
		case OTRL_MSGEVENT_LOG_HEARTBEAT_RCVD:
		case OTRL_MSGEVENT_LOG_HEARTBEAT_SENT:
		{
			NSLog(@"AI Core is still online ~");
			break;
		}
			
		case OTRL_MSGEVENT_RCVDMSG_GENERAL_ERR:
		{
			NSLog(@"Something went very wrong: %s", message);
			break;
		}
			
		case OTRL_MSGEVENT_RCVDMSG_UNENCRYPTED:
		{
#warning "We received an unencrypted message :CCCC"
			break;
		}
			
		case OTRL_MSGEVENT_RCVDMSG_FOR_OTHER_INSTANCE:
		{
			NSLog(@"We shouldn't have received this message :o");
			break;
		}
			
		case OTRL_MSGEVENT_NONE:
		{
			break;
		}
	}
}

#pragma mark - Few more utils

void closeSessionFromRootContext(OtrlUserState state)
{
	ConnContext * currentContext = state->context_root, * nextContext;
	OtrlMessageAppOps jumptable = [FlamingOTRAccount getJumptable];

	while(currentContext != NULL)
	{
		nextContext = currentContext->next;
		
		if (currentContext->msgstate == OTRL_MSGSTATE_ENCRYPTED && currentContext->protocol_version > 1)
		{
			otrl_message_disconnect_all_instances(state, &jumptable, NULL,
												  currentContext->accountname,
												  currentContext->protocol,
												  currentContext->username);
		}
		
		currentContext = nextContext;
	}

}
