//
//  FlamingOTR.m
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#include <pthread/pthread.h>

static FlamingOTR * singleton = nil;

@interface FlamingOTR ()
{
	NSMutableDictionary * sessionController;
	
	pthread_mutex_t tokenMutex;
}

@end

@implementation FlamingOTR

+ (instancetype) getShared
{
	if(singleton == nil)
	{
		singleton = [[FlamingOTR alloc] init];
	}
	
	return singleton;
}

- (instancetype) init
{
	self = [super init];
	
	if(self != nil)
	{
		pthread_mutex_init(&tokenMutex, NULL);
		sessionController = [NSMutableDictionary new];
	}
	
	return self;
}

- (void) dealloc
{
	pthread_mutex_destroy(&tokenMutex);
}

#pragma mark - Session tools

- (FlamingOTRAccount *) getContextForAccount : (FGOAccount *) account
{
	NSString * signature = [FlamingOTRAccount signatureForAccount:account];
	
	FlamingOTRAccount * output = [sessionController objectForKey:signature];
	
	if(output == nil)
	{
		output = [[FlamingOTRAccount alloc] initWithAccount:account];

		if(output != nil)
		{
			[sessionController setObject:output forKey:signature];
		}
	}
	
	return output;
}

- (FlamingOTRAccount *) getContextForSignature : (NSString *) signature
{
	return [sessionController objectForKey:signature];
}

@end
