//
//  hooker.m
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

static void __attribute__((constructor)) initialize(void);

void initialize()
{
	NSLog(@"Initialized!");
}
