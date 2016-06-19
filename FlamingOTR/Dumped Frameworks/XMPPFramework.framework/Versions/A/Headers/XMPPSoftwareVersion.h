//
//  XMPPSoftwareVersion.h
//  XMPPFramework
//
//  Created by Indragie Karunaratne on 2013-02-05.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>

extern NSString* const XMLNSJabberIQVersion; // @"jabber:iq:version"

/* 
 * XEP-0092 implementation that handles queries for jabber:iq:version
 * and returns software and operating system version information
 */
@interface XMPPSoftwareVersion : XMPPModule
/*
 * The name of the XMPP client application
 */
@property (nonatomic, copy) NSString *applicationName;
/*
 * The version of the XMPP client application as a string
 */
@property (nonatomic, copy) NSString *applicationVersion;
@end
