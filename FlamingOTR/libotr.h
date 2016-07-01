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

#endif /* libotr_h */
