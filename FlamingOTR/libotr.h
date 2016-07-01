//
//  libotr.h
//  FlamingOTR
//
//  Created by Taiki on 25/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#ifndef libotr_h
#define libotr_h

#include <proto.h>
#include <privkey.h>
#include <message.h>

//Callbacks
const char * account_name(void *opdata, const char *account, const char *protocol);
void account_name_free(void *opdata, const char *account_name);

void gone_secure(void *opdata, ConnContext *context);
void gone_insecure (void *opdata, ConnContext *context);

void create_privkey(void *opdata, const char *accountname, const char *protocol);
OtrlPolicy get_policy(void *opdata, ConnContext *context);

void inject_message(void *opdata, const char *accountname, const char *protocol, const char *recipient, const char *message);

int is_logged_in(void *opdata, const char *accountname, const char *protocol, const char *recipient);
void new_fingerprint(void *opdata, OtrlUserState us, const char *accountname, const char *protocol, const char *username, unsigned char fingerprint[20]);
void write_fingerprints(void *opdata);
void timer_control(void *opdata, unsigned int interval);
void received_symkey(void *opdata, ConnContext *context, unsigned int use, const unsigned char *usedata, size_t usedatalen, const unsigned char *symkey);

const char * otr_error_message(void *opdata, ConnContext *context, OtrlErrorCode err_code);
void otr_error_message_free(void *opdata, const char *err_msg);

void handle_smp_event(void *opdata, OtrlSMPEvent smp_event, ConnContext *context, unsigned short progress_percent, char *question);
void handle_msg_event(void *opdata, OtrlMessageEvent msg_event, ConnContext *context, const char *message, gcry_error_t err);

void closeSessionFromRootContext(OtrlUserState state);

#endif /* libotr_h */
