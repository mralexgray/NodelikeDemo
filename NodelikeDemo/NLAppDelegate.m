
//  NLAppDelegate.m
//  NodelikeDemo

//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.

#import "NLAppDelegate.h"
#import "Nodelike.h"

@implementation NLAppDelegate { NLContext *context; }

- (BOOL) application:(UIApplication*)a didFinishLaunchingWithOptions:(NSDictionary*)o {

    return context					 = [NLContext.alloc initWithVirtualMachine:JSVirtualMachine.new],
    context.exceptionHandler = ^(JSContext *c, JSValue *e) { NSLog(@"%@", e); }, YES;
}
- (NSString*) execute:(NSString*)cmd { return	[context requireModule:@"index"],
																							[context evaluateScript:cmd],
																							[context[@"_"]toString];					}
 @end
