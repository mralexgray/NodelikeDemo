//
//  NLProcess.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol			  NLProcessJSExports <JSExport>

@property	(readonly)   		NSArray * argv;
@property	(readonly) NSDictionary * env;
@property (readonly)     NSString * cwd, * platform;

- (void) chdir:				  (NSString*)path;
- (void) exit:					(NSNumber*)code;
- (void) nextTick:			 (JSValue*)cb;
-   (id) binding:				(NSString*)binding;
@end

@interface					    NLProcess : NSObject <NLProcessJSExports>

@property									NSArray * argv;
@property								 NSString * platform;
@property					   NSDictionary * env;

@end
