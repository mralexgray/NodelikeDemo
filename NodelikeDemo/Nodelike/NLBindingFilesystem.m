//
//  NLBindingFilesystem.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingFilesystem.h"

#import "NLBindingBuffer.h"

@implementation NLBindingFilesystem

- (id) init {	return self = [super init] ?

	_Stats = [JSValue valueWithNewObjectInContext:JSContext.currentContext],
	_Stats[@"prototype"] = [JSValue valueWithNewObjectInContext:JSContext.currentContext], self : nil;
}

static void after(uv_fs_t* req) {
	[NLContext finishEventRequest:req do:^(NLContext *context) {
		req->result < 0 ? [context setErrorCode:(int)req->result forEventRequest:req] : [context callSuccessfulEventRequest:req];
		uv_fs_req_cleanup(req);
	}];
}

#define CALL(fun, cb, ...)                                  \
NLContext createEventRequestOfType:UV_FS withCallback:cb do:\
^(uv_loop_t *loop, void *req, bool async) {                 \
uv_fs_ ## fun(loop, req, __VA_ARGS__, async ? after : nil); \
if (!async) after(req);                                     \
} then:

- (JSValue*) open:(NSString*)path flags:(NSNumber*)flags mode:(NSNumber*)mode callback:(JSValue*)cb {

	return [CALL(open, cb, strdup(path.UTF8String), flags.intValue, mode.intValue)^(void *req_, NLContext *context) {		uv_fs_t *req = req_;
    [context setValue:[JSValue valueWithInt32:(int32_t)req->result inContext:context] forEventRequest:req];
	}];
}
- (JSValue*) close:(NSNumber*)file callback:(JSValue*)cb { return [CALL(close, cb, file.intValue) nil]; }

- (JSValue*) read:(NSNumber*)file to:(JSValue*)target offset:(JSValue*)off length:(JSValue*)len pos:(JSValue*)pos callback:(JSValue*)cb {

	unsigned int buffer_length = [target[@"length"] toUInt32],
											length = off.isUndefined ? buffer_length : off.toUInt32,
										position = pos.isUndefined ?             0 : pos.toUInt32;
	return [CALL(read, cb, file.intValue, malloc(length), length, position)^(void *req_, NLContext *context) {
		uv_fs_t *req = req_;
		NSData *data = [NSData dataWithBytesNoCopy:req->buf length:length freeWhenDone:YES];
		[NLBindingBuffer writeData:data toBuffer:target atOffset:off withLength:len];
		[context setValue:[JSValue valueWithInt32:(int32_t)req->result inContext:context] forEventRequest:req];
	}];
}

- (JSValue*) readDir:(NSString*)path callback:(JSValue*)cb {
	return [CALL(readdir, cb, strdup(path.UTF8String), 0)
					^(void *req_, NLContext *context) {
						uv_fs_t *req		= req_;
						char *namebuf		= req->ptr;
						int i, nnames		= (int)req->result;
						JSValue *names	= [JSValue valueWithNewArrayInContext:context];
						for (i = 0; i < nnames; i++) {
							names[i] = [NSString stringWithUTF8String:namebuf];
							namebuf += strlen(namebuf) + 1;
						}
						[context setValue:names forEventRequest:req];
					}];
}

- (JSValue*) fdatasync:(NSNumber*)file callback:(JSValue*)cb { return [CALL(fdatasync, cb, file.intValue) nil]; }

- (JSValue*) fsync:(NSNumber*)file callback:(JSValue*)cb {
	return [CALL(fsync, cb, [file intValue]) nil];
}

- (JSValue*) rename:(NSString*)oldpath to:(NSString*)newpath callback:(JSValue*)cb {
	return [CALL(rename, cb, strdup([oldpath UTF8String]), strdup([newpath UTF8String])) nil];
}

- (JSValue*) ftruncate:(NSNumber*)file length:(NSNumber*)len callback:(JSValue*)cb {
	return [CALL(ftruncate, cb, [file intValue], [len intValue]) nil];
}

- (JSValue*) rmdir:(NSString*)path callback:(JSValue*)cb {
	return [CALL(rmdir, cb, strdup([path UTF8String])) nil];
}

- (JSValue*) mkdir:(NSString*)path mode:(NSNumber*)mode callback:(JSValue*)cb {
	return [CALL(mkdir, cb, strdup([path UTF8String]), [mode intValue]) nil];
}

- (JSValue*) link:(NSString*)dst from:(NSString*)src callback:(JSValue*)cb {
	return [CALL(link, cb, strdup([dst UTF8String]), strdup([src UTF8String])) nil];
}

- (JSValue*) symlink:(NSString*)dst from:(NSString*)src mode:(NSString*)mode callback:(JSValue*)cb {
	// we ignore the mode argument because it is only effective on windows platforms
	return [CALL(symlink, cb, strdup([dst UTF8String]), strdup([src UTF8String]), 0 /*flags*/) nil];
}

- (JSValue*) readlink:(NSString*)path callback:(JSValue*)cb {
	return [CALL(readlink, cb, strdup(path.UTF8String)) ^(void *req_, NLContext *context) {
		uv_fs_t *req = req_;
		NSString *str = [NSString stringWithCString:req->ptr encoding:NSUTF8StringEncoding];
		[context setValue:[JSValue valueWithObject:str inContext:context] forEventRequest:req];
	}];
}

- (JSValue*) unlink:(NSString*)path callback:(JSValue*)cb {
	return [CALL(unlink, cb, strdup(path.UTF8String)) nil];
}

- (JSValue*) chmod:(NSString*)path mode:(NSNumber*)mode callback:(JSValue*)cb {
	return [CALL(chmod, cb, strdup(path.UTF8String), mode.intValue) nil];
}

- (JSValue*) fchmod:(NSNumber*)file mode:(NSNumber*)mode callback:(JSValue*)cb {
	return [CALL(fchmod, cb, file.intValue, mode.intValue) nil];
}

- (JSValue*) chown:(NSString*)path uid:(NSNumber*)uid_ gid:(NSNumber*)gid_ callback:(JSValue*)cb {
	uv_uid_t uid = uid_.unsignedIntValue;
	uv_gid_t gid = gid_.unsignedIntValue;
	return [CALL(chown, cb, strdup(path.UTF8String), uid, gid) nil];
}

- (JSValue*) fchown:(NSNumber*)file uid:(NSNumber*)uid_ gid:(NSNumber*)gid_ callback:(JSValue*)cb {
	uv_uid_t uid = uid_.unsignedIntValue;
	uv_gid_t gid = gid_.unsignedIntValue;
	return [CALL(fchown, cb, file.intValue, uid, gid) nil];
}

@end
