//
//  NLBinding.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBinding.h"

#import "NLBindingFilesystem.h"
#import "NLBindingConstants.h"
#import "NLBindingSmalloc.h"
#import "NLBindingBuffer.h"
#import "NLBindingTimerWrap.h"
#import "NLBindingCaresWrap.h"

@implementation NLBinding

+ (NSCache*)bindingCache {

	         static NSCache *cache = nil;	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{ cache = NSCache.new; });																return cache;
}
+ (NSDictionary*)bindings {

	     static NSDictionary *bindings = nil;  static dispatch_once_t token = 0;
	dispatch_once(&token, ^{	bindings = @{ @"fs" : NLBindingFilesystem.class,
																	 @"constants" : NLBindingConstants.class,
																		 @"smalloc" : NLBindingSmalloc.class,
																			@"buffer" : NLBindingBuffer.class,
																	@"timer_wrap" : NLBindingTimerWrap.class,
																	@"cares_wrap" : NLBindingCaresWrap.class }; });  return bindings;
}
+ (id)bindingForIdentifier:(NSString*)identifier {     id binding; Class cls;

    NSCache *cache = NLBinding.bindingCache;
    if (!(binding = [cache objectForKey:identifier]) || !(cls = NLBinding.bindings[identifier])) return nil;
		binding = [[cls.alloc init]binding];
		[cache setObject:binding forKey:identifier];
		return binding;
}
- (id)binding { return self; }

@end
