//
//  XMPPOAuth2Authentication.h
//  XMPPFramework
//
//  Created by Indragie Karunaratne on 2013-06-02.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPStream.h"
#import "XMPPSASLAuthentication.h"

// Implement's Google's OAuth2 SASL authentication mechanism
// as documented at <https://developers.google.com/talk/jep_extensions/oauth>
@interface XMPPOAuth2Authentication : NSObject <XMPPSASLAuthentication>

@end

@interface XMPPStream (XMPPOAuth2Authentication)
- (BOOL)supportsOAuth2Authentication;
@end

