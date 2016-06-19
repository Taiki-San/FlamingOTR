//
//  FlamingOTR.h
//  FlamingOTR
//
//  Created by Taiki on 07/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlamingOTR : NSObject

+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector;
+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector fromClass : (Class) injectionClass;

+ (void) addSelector : (SEL) selector ofClass : (Class) originalClass toClass : (Class) targetClass;

@end
