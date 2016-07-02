//
//  FOTRUserContext.swift
//  FlamingOTR
//
//  Created by Taiki on 26/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

import Foundation

@objc class UserContext : NSObject
{
	var accountID : String
	
	var OTRState: OtrlUserState?
	var isInitialized = false
	var hasPrivateKey = false
	
	init?(account : String)
	{
		self.accountID = account;
		self.OTRState = otrl_userstate_create()
		
		super.init()
		
		//Initialization was successfull
		if self.OTRState != nil
		{
			if !self.loadContext()
			{
				return nil
			}
		}
	}
	
	deinit
	{
		if self.OTRState != nil
		{
			//Release the various sessions
			closeSessionFromRootContext(self.OTRState)
			
			self.saveContext()
			otrl_userstate_free(self.OTRState)
		}
	}
}

extension UserContext
{
	func loadContext() -> Bool
	{
		var path = ("pk_" + accountID + ".pk")
		var error = gcry_err_code(path.withCString { otrl_privkey_read(self.OTRState, $0) })

		//Couldn't load the PK for some reason
		if error != GPG_ERR_NO_ERROR
		{
			//If the error is more complex that just a missing file
			if error != GPG_ERR_ENOENT
			{
				NSLog("Couldn't load private key for account " + accountID)
				return false
			}

			//Generate a new PK
			var newPKContext : UnsafeMutablePointer<Void>?
			error = gcry_err_code( path.withCString{ otrl_privkey_generate_start(self.OTRState, $0, DEFAULT_PROTOCOL, &newPKContext) })
			
			if error != GPG_ERR_NO_ERROR
			{
				NSLog("Trying to generate a new private key, but one is already computing, wtf?! (error code \(error)");
				return false
			}
			
			let pkFilePath = path

			//Throw the actual computation in the background
			DispatchQueue(label: "fr.taiki.fotr.pk_generation").async(execute: {
				
				otrl_privkey_generate_calculate(newPKContext)
				
				//Post process back in the main thread
				DispatchQueue.main.async(execute: {
					
					error = gcry_err_code( pkFilePath.withCString { otrl_privkey_generate_finish(self.OTRState, newPKContext, $0) })
					if error != GPG_ERR_NO_ERROR
					{
						NSLog("Couldn't generate a private key for" + self.accountID)
					}
					else
					{
						//Try to load the newly generated PK in the account
						error = gcry_err_code( pkFilePath.withCString { otrl_privkey_read(self.OTRState, $0) })
						
						if error != GPG_ERR_NO_ERROR
						{
							NSLog("Couldn't use the newly generated private key, wat?")
						}
						else
						{
							self.hasPrivateKey = true;
						}
					}
				})
			});
		}
		else
		{
			hasPrivateKey = true
		}
		
		//Load metadata
		path = ("tag_" + accountID + ".tag")
		error = gcry_err_code( path.withCString { otrl_instag_read(self.OTRState, $0) })
		if error != GPG_ERR_NO_ERROR
		{
			//If the error is more complex that just a missing file
			if error != GPG_ERR_ENOENT
			{
				NSLog("Couldn't load tags for account " + accountID)
				return false
			}
			
			//If we just need a new instance
			error = gcry_err_code( path.withCString({cPath in
				accountID.withCString({ cAccount in
					otrl_instag_generate(self.OTRState, cPath, cAccount, DEFAULT_PROTOCOL)
				})
			}))
		}
		
		path = ("fp_" + accountID + ".fp")
		error = gcry_err_code( path.withCString { otrl_privkey_read_fingerprints(self.OTRState, $0, nil, nil) })
		if error != GPG_ERR_NO_ERROR
		{
			NSLog("Couldn't load fingerprints for account " + accountID)
		}
		
		return true
	}
	
	func triggerFingerprintSync()
	{
		_ = ("fp_" + accountID + ".fp").withCString	{	otrl_privkey_write_fingerprints(self.OTRState, $0)	}
	}
	
	func saveContext()
	{
		if !isInitialized
		{
			return
		}
		
		_ = ("tag_" + accountID + ".tag").withCString	{	otrl_instag_write(self.OTRState, $0)	}
		_ = ("fp_" + accountID + ".fp").withCString	{	otrl_privkey_write_fingerprints(self.OTRState, $0)	}
	}
}
