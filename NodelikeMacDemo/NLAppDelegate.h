
/*  NLAppDelegate.h  NodelikeMacDemo
		Created by Alex Gray on 10/24/13. Copyright (c) 2013 Sam Rijs. All rights reserved. */

#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JSContextRef.h>
#import <WebKit/WebKit.h>
#import "Nodelike.h"

#define  WK weak
#define  AS assign
#define  RO readonly
#define  NA nonatomic
#define IBO IBOutlet

@interface				    NLAppDelegate : NSObject

@property (AS) IBO       NSTextView * console,    // Console is on top (for typing into).
																		* log;        //	Log is below, and is for both NS and JS enties.
@property (WK) IBO		      WebView	* variables;

@property (WK) IBOutlet  NSOutlineView * cmdOutline; // The drawer view that holds the clickable built-ins for testing.
@property (WK) IBO NSTreeController * cmdTree;
@property (RO)              NSArray * cmds;	 // Tree controller items, "built in" commands.  Needs more!

@property							    NLContext * context;
@property (NA)              JSValue * interpretation;

@property										 NSFont * font;
@property (RO)   NSAttributedString * resultString;
@property				NSMutableDictionary * jsVars;
@end

@interface WebView (CSS)
- (void) injectCSS:(NSString*)css;
@end

@interface NSString (InRange)
- (BOOL) containsSet:(NSCharacterSet*)set inRange:(NSRange)r;
@property (readonly) BOOL isOnlyWhitespace;
@end

#define JSSENTINEL ({ static NSCharacterSet * set; set = set ?: ({ \
  NSMutableCharacterSet *mset = NSCharacterSet.newlineCharacterSet;\
  [mset formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@";"]]; mset; }); set; })


#define NODEWITH(X)		[NSTreeNode treeNodeWithRepresentedObject:X]
#define NOTCENTER     NSNotificationCenter.defaultCenter
#define OBSERVE(X,Y) 	[NOTCENTER addObserverForName:X object:nil queue:NSOperationQueue.mainQueue \
                                         usingBlock:^(NSNotification *note) { Y }]


//NS_INLINE void AppendDiv(NSString*css,WebView*wv) { DOMDocument *  domD = wv.mainFrameDocument; DOMElement* styleE = [domD createElement:@"style"],
//																															  * headE = domD.
//
//
//																															  * headE = (DOMElement*)[[domD getElementsByTagName:@"head"] item:0];
//
//	[styleE setAttribute:@"type" value:@"text/css"]; [styleE appendChild:[domD createTextNode:css]];  [headE appendChild:styleE];
//}


@interface NLAppDelegate () <NSApplicationDelegate , NSOutlineViewDataSource>
@property (AS) IBO         NSWindow * window;
@end
