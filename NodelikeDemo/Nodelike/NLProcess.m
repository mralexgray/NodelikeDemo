//
//  NLProcess.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLProcess.h"
#import "NLBinding.h"

@implementation NLProcess { NSFileManager *filemngr; } @synthesize argv = _argv, env = _env, platform = _platform;

-        (id) init													{ return self = super.init ? filemngr = NSFileManager.new,
																								_platform = @"darwin",
																										_argv	= NSProcessInfo.processInfo.arguments,
																										_env	= NSProcessInfo.processInfo.environment, self : nil;
}
- (NSString*) cwd														{ return filemngr.currentDirectoryPath;																								}
-      (void) chdir:		(NSString*)path			{ [filemngr changeCurrentDirectoryPath:path];																					}
-      (void) exit:			(NSNumber*)code			{ exit(code.intValue);																																}
-			 (void) nextTick:	(JSValue*)cb				{ dispatch_async(dispatch_get_main_queue(), ^(void){ [cb callWithArguments:@[]]; });	}
-        (id) binding:	(NSString*)binding	{ return [NLBinding bindingForIdentifier:binding];																		}

@end
