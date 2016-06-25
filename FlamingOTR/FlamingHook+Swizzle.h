//
//  FlamingHook_FlamingHook_Swizzle.h
//  FlamingOTR
//
//  Created by Taiki on 25/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

#import "FlamingHook.h"

@implementation FlamingHook (Swizzle)

//Implementation based on the excellent blog post available at http://nshipster.com/method-swizzling/

+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector
{
	[self swizzleClass:class originalMethod:originalSelector withMethod:swizzledSelector fromClass:class];
}

+ (void) swizzleClass : (Class) class originalMethod : (SEL) originalSelector withMethod : (SEL) swizzledSelector fromClass : (Class) injectionClass
{
	Method originalMethod = class_getInstanceMethod(class, originalSelector);
	Method swizzledMethod = class_getInstanceMethod(injectionClass, swizzledSelector);
	
	if(originalMethod != NULL && swizzledMethod != NULL)
	{
		BOOL didAddMethod = class_addMethod(class,
											swizzledSelector,
											method_getImplementation(originalMethod),
											method_getTypeEncoding(originalMethod));
		
		if (didAddMethod)
		{
			class_replaceMethod(class,
								originalSelector,
								method_getImplementation(swizzledMethod),
								method_getTypeEncoding(swizzledMethod));
		}
		else
		{
			method_exchangeImplementations(originalMethod, swizzledMethod);
		}
	}
	else
	{
		if(originalMethod != NULL)
			NSLog(@"Couldn't find %@ in %@", NSStringFromSelector(swizzledSelector), NSStringFromClass(injectionClass));
		
		else if(swizzledMethod != NULL)
			NSLog(@"Couldn't find %@ in %@", NSStringFromSelector(originalSelector), NSStringFromClass(class));
		
		else
			NSLog(@"Couldn't find either %@ or %@ in %@", NSStringFromSelector(originalSelector), NSStringFromSelector(swizzledSelector), NSStringFromClass(class));
	}
}

+ (void) addSelector : (SEL) selector ofClass : (Class) originalClass toClass : (Class) targetClass
{
	Method method = class_getInstanceMethod(originalClass, selector);
	Method previousHit = class_getInstanceMethod(targetClass, selector);
	
	if(method == NULL)
	{
		NSLog(@"Couldn't locate the method to inject");
	}
	else if(previousHit != NULL)
	{
		NSLog(@"Selector %@ already exist in class %@ (inserting from %@)", NSStringFromSelector(selector), NSStringFromClass(targetClass), NSStringFromClass(originalClass));
	}
	else
	{
		class_addMethod(targetClass,
						selector,
						method_getImplementation(method),
						method_getTypeEncoding(method));
	}
}

@end
