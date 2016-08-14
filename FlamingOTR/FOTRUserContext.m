//
//  FOTRUserContext.m
//  FlamingOTR
//
//  Created by Taiki on 13/08/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

@implementation FOTRUserContext

- (instancetype) initWithAccount : (NSString *) account
{
	self = [super init];
	
	if(self != nil)
	{
		_accountID = account;
		_OTRState = otrl_userstate_create();
		
		//Initialization was successfull
		if(_OTRState == nil || ![self loadContext])
			self = nil;
	}
	
	return self;
}

- (void) dealloc
{
	if(_OTRState != nil)
	{
		//Release the various sessions
		closeSessionFromRootContext(_OTRState);
		
		[self saveContext];
		otrl_userstate_free(_OTRState);
	}
}

- (BOOL) loadContext
{
	NSString * path = [NSString stringWithFormat:@"pk_%@.pk", _accountID];
	gcry_err_code_t error = gcry_err_code(otrl_privkey_read(_OTRState, path.UTF8String));
	
	//Couldn't load the PK for some reason
	if(error != GPG_ERR_NO_ERROR)
	{
		//If the error is more complex that just a missing file
		if(error != GPG_ERR_ENOENT)
		{
			NSLog(@"Couldn't load private key for account %@", _accountID);
			return NO;
		}
		
		//Generate a new PK
		void * newPKContext = NULL;
		error = gcry_err_code(otrl_privkey_generate_start(_OTRState, _accountID.UTF8String, DEFAULT_PROTOCOL, &newPKContext));
		
		if(error != GPG_ERR_NO_ERROR)
		{
			NSLog(@"Trying to generate a new private key, but one is already computing, wtf?! (error code %d)", error);
			return false;
		}
		
		NSString * pkFilePath = [path copy];
		//Throw the actual computation in the background
		dispatch_async(dispatch_queue_create("fr.taiki.fotr.pk_generation", DISPATCH_QUEUE_SERIAL), ^{
			
			otrl_privkey_generate_calculate(newPKContext);
			
			//Post process back in the main thread
			dispatch_async(dispatch_get_main_queue(), ^{
				
				gcry_err_code_t localError = gcry_err_code(otrl_privkey_generate_finish(self.OTRState, newPKContext, pkFilePath.UTF8String));
				if(localError != GPG_ERR_NO_ERROR)
				{
					NSLog(@"Couldn't generate a private key for %@", self.accountID);
				}
				else
				{
					//Try to load the newly generated PK in the account
					localError = gcry_err_code(otrl_privkey_read(self.OTRState, pkFilePath.UTF8String));
					
					if(localError != GPG_ERR_NO_ERROR)
					{
						NSLog(@"Couldn't use the newly generated private key, wat? (error %d)", localError);
					}
					else
					{
						self->hasPrivateKey = true;
					}
				}
			});
		});
	}
	else
	{
		hasPrivateKey = true;
	}
	
	//Load metadata
	path = [NSString stringWithFormat:@"tag_%@.tag", _accountID];
	error = gcry_err_code(otrl_instag_read(_OTRState, path.UTF8String));
	if(error != GPG_ERR_NO_ERROR)
	{
		//If the error is more complex that just a missing file
		if(error != GPG_ERR_ENOENT)
		{
			NSLog(@"Couldn't load tags for account %@", _accountID);
			return false;
		}
		
		//If we just need a new instance
		error = gcry_err_code(otrl_instag_generate(_OTRState, path.UTF8String, _accountID.UTF8String, DEFAULT_PROTOCOL));
	}
	
	path = [NSString stringWithFormat:@"fp_%@.fp", _accountID];
	error = gcry_err_code(otrl_privkey_read_fingerprints(_OTRState, path.UTF8String, NULL, NULL));

	if(error != GPG_ERR_NO_ERROR)
		NSLog(@"Couldn't load fingerprints for account %@", _accountID);
	
	return true;
}

- (void) triggerFingerprintSync
{
	otrl_privkey_write_fingerprints(_OTRState, [NSString stringWithFormat:@"fp_%@.fp", _accountID].UTF8String);
}

- (void) saveContext
{
	if(isInitialized)
	{
		otrl_instag_write(_OTRState, [NSString stringWithFormat:@"tag_%@.tag", _accountID].UTF8String);
		otrl_privkey_write_fingerprints(_OTRState, [NSString stringWithFormat:@"fp_%@.fp", _accountID].UTF8String);
	}
}

@end
