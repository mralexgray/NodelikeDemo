
/*  NLAppDelegate.h  NodelikeMacDemo
		Created by Alex Gray on 10/24/13. Copyright (c) 2013 Sam Rijs. All rights reserved. */

#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JSContextRef.h>
#import <WebKit/WebKit.h>


#define  WK weak
#define  AS assign
#define  RO readonly
#define  NA nonatomic
#define IBO IBOutlet

@interface				    NLAppDelegate : NSObject
						 <NSApplicationDelegate , NSOutlineViewDataSource>

@property										 NSFont * font;
@property (NA)			 NSMutableArray * cmds;								// Provides tree controller content, with "built in" commands.  Needs more!
@property (RO)   NSAttributedString * resultString;
@property (AS) IBO         NSWindow * window;
@property (AS) IBO       NSTextView * console,
																		* log;			// Console is on top (for typing into).  Log is below, and is for both NS and JS enties.
@property (WK) IBO		      WebView	* variables;
@property				NSMutableDictionary * jsVars;
@property (NA) JSValue * interpretation;
@end


NS_INLINE void InjectCSS(NSString*css,WebView*wv) { DOMDocument *  domD = wv.mainFrameDocument; DOMElement* styleE = [domD createElement:@"style"],
																															  * headE = (DOMElement*)[[domD getElementsByTagName:@"head"] item:0];

	[styleE setAttribute:@"type" value:@"text/css"]; [styleE appendChild:[domD createTextNode:css]];  [headE appendChild:styleE];
}
//NS_INLINE void AppendDiv(NSString*css,WebView*wv) { DOMDocument *  domD = wv.mainFrameDocument; DOMElement* styleE = [domD createElement:@"style"],
//																															  * headE = domD.
//
//
//																															  * headE = (DOMElement*)[[domD getElementsByTagName:@"head"] item:0];
//
//	[styleE setAttribute:@"type" value:@"text/css"]; [styleE appendChild:[domD createTextNode:css]];  [headE appendChild:styleE];
//}


