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

	NSString * signature = [NSString stringWithUTF8String:_account];
	if(signature != nil)
	{
		FlamingOTRAccount * account = [[FlamingOTR getShared] getContextForSignature:signature];
		if(account != nil)
		{
			output = strdup(account.username.UTF8String);
		}
	}
	
	return output;
}

void account_name_free(void *opdata, const char *account_name)
{
	free((void*) account_name);
}
