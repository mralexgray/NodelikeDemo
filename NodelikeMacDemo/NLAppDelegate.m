/*  NLAppDelegate.m  NodelikeMacDemo
		Created by Alex Gray on 10/24/13. Copyright (c) 2013 Sam Rijs. All rights reserved. */

//  @property (NA)					   NSString * evalString;
//	[_variables.mainFrame bind:@"stringValue" toObject:self withKeyPath:@"resultString" options:nil]; 

#import "NLAppDelegate.h"

@implementation   NLAppDelegate

- (void) awakeFromNib {	[_window.drawers[0] open];  // Open drawer on window.

  // setup JSVirtualMachine.  woohoo.
  _context = [NLContext.alloc initWithVirtualMachine:JSVirtualMachine.new];
	_interpretation = [JSValue valueWithObject:@"_" inContext:_context];

	[_variables.mainFrame.DOMDocument bind:@"nodeValue"
                                toObject:_interpretation withKeyPath:@"toString"
                                 options:@{NSNullPlaceholderBindingOption:NSNull.null}];

	__block NSTextView *log_  = _log;
  _context.exceptionHandler = ^(JSContext *c, JSValue *e) {
    log_.string = [log_.string stringByAppendingFormat:@"\n%@",e]; NSLog(@"%@", e);
  };

//	[self bind:@"resultString" toObject:self withKeyPath:@"interpretation" options:@{NSNullPlaceholderBindingOption:NSNull.null}];

  OBSERVE(NSTextDidChangeNotification, ({ // detect return and semicolons...  then RUN!

    NSTextView * txtV = note.object;
    NSString    * txt = txtV.textStorage.string;

    [txtV.enclosingScrollView scrollPoint:txtV.frame.origin];

    if(!txt.length || txt.isOnlyWhitespace || ![txt containsSet:JSSENTINEL inRange:(NSRange){txt.length-1,1}]) return;

			NSLog(@"txt:%@mainframe... %@", txt, _variables.mainFrame.DOMDocument.childNodes);

			[_context requireModule:@"index"];
      self.interpretation = [_context evaluateScript:txt];
      [_variables.mainFrame loadHTMLString:
				[[_variables.mainFrame.DOMDocument body].innerHTML stringByAppendingFormat:@"<div style='background-color:rgba(%@,%@,%@, 1);'>%@</div>"
																	,@(arc4random() %255),@(arc4random() %255), @(arc4random() %255), _interpretation.toString] baseURL:nil];
			[_variables.windowScriptObject evaluateWebScript:@"window.scrollTo(0, document.body.scrollHeight);"];

}););}
//[_context requireModule:@"http"];
//			[self willChangeValueForKey:@"resultString"];
//			id rand = @(arc4random() %500).stringValue;
//			[self didChangeValueForKey:@"resultString"];

- (NSString*) selectedOutlineItem:(NSOutlineView*)v { return [[[v itemAtRow:v.selectedRow]representedObject]representedObject]; }

- (IBAction) insertCommand:(id)tableSender {
	[_console insertText:[NSAttributedString.alloc initWithString:[self selectedOutlineItem:tableSender] attributes:@{NSFontNameAttribute:_font}]];
}
- (NSArray*) cmds { static NSMutableArray *_cmds;

  return _cmds ?: ^{ _cmds	= NSMutableArray.new;	// tree controller's "content" set in IB

    // Only doing these UI setup things HERE... because there's a good chance this will only get called once..
		_console.textColor	= _log.textColor	=	 _console.insertionPointColor = NSColor.whiteColor;
		_console.font				= _font						= [NSFont fontWithName:@"AmericanTypewriter" size:22];
													_log.font				= [NSFont fontWithName:@"AmericanTypewriter" size:15];  // end UI silliness.
		[_variables injectCSS:GRIDLYCSS];
		[_variables.windowScriptObject evaluateWebScript:[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://mrgray.com/jq"] encoding:NSUTF8StringEncoding error:nil]];

    // Reuse this var as we build a tree of nodes.. of "available" node commands.. in the outline view.
		__block NSTreeNode *node;

		// this is just a block helper to add a bunch of child nodes under a group, like process, ad its subcommands.

		void(^add)(NSArray*)	= ^(NSArray *z) { for (id x in z) [node.mutableChildNodes addObject:NODEWITH(x)]; };

		node = NODEWITH(@"process");	add(@[@".cwd()",@".chdir()",@".argv",@".env",@".exit()",@".nextTick()"]); // adds to node.
		[_cmds addObject:node];                                                   // add too array.
		[_cmds addObject:NODEWITH(@"require()")];																	// new single item node.
							node = NODEWITH(@"fs");	add(@[@"open", @"close", @"readdir"]);  // new multi-item node.
		[_cmds addObject:node];																								// add multi-item to array
		[_cmds addObjectsFromArray:@[	NODEWITH(@"util"),    NODEWITH(@"url"),       NODEWITH(@"events"),
                                  NODEWITH(@"path"),    NODEWITH(@"stream"),    NODEWITH(@"querystring"),
                                  NODEWITH(@"assert"),  NODEWITH(@"punycode")]];

		return _cmds;	// return our commands array.. which was why we ended up in this big block to begin with.
	}();
}
+ (NSSet*) keyPathsForValuesAffectingResultString { return [NSSet setWithObjects:@"evalString", nil]; } // KVO

- (NSAttributedString*) resultString {

//	id y, z, x =	!_context ? @"" : z != [_context class] ? @"" : y != [z currentThis] ? @"" : [y toString];
//			id z, x = !_context ? @"" : z != _context[@"_"] ? @"" : [z toString] ?: @"";
	return [NSAttributedString.alloc initWithString:_interpretation ? _interpretation.toString : @"" attributes:!_font ? nil : @{NSFontNameAttribute:_font}];
//	  [@"_ = " stringByAppendingString:x]
}
//	[self appendString:selectedItem toView:_console];
//	[[[_commands.arrangedObjects descendantNodeAtIndexPath:[NSIndexPath indexPathWithIndex:[sender selectedRow]]]representedObject]representedObject]];
//- (void) appendString:(NSString*)text toView:(id)view { }

@end

int main(int argc, const char * argv[])	{	return NSApplicationMain(argc, argv);	}



@implementation WebView (CSS)
- (void) injectCSS:(NSString*)css {

  DOMDocument  * domD = self.mainFrameDocument;
  DOMElement * styleE = [domD createElement:@"style"];

	[styleE setAttribute:@"type" value:@"text/css"];
  [styleE appendChild:[domD createTextNode:css]];
  [[[domD getElementsByTagName:@"head"] item:0] appendChild:styleE]; // head
}
@end

@implementation NSString (InRange)
- (BOOL) containsSet:(NSCharacterSet*)set inRange:(NSRange)r {

    return [[self substringWithRange:r] rangeOfCharacterFromSet:set].location != NSNotFound;

}
- (BOOL) isOnlyWhitespace {
  return ![self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length;
}
@end



//
//		if ([cmd isKindOfClass:NSString.class]) [_commandContent addObject:[NSTreeNode treeNodeWithRepresentedObject:cmd]];
//		else {
//			NSTreeNode *group = [NSTreeNode treeNodeWithRepresentedObject:[cmd allKeys][0]];
//				for (id key in [cmd allKeys])
//					[group.mutableChildNodes addObject:[NSTreeNode treeNodeWithRepresentedObject:key]];
//			[_commandContent addObject:group];
//		}
//		return _commandContent;

//- (void) insertCommand:(id) sender {
//		NSLog(@"%@", [_commands.arrangedObjects descendantNodeAtIndexPath:[NSIndexPath indexPathWithIndex:[sender selectedRow]]]);// objectAtIndex:[sender selectedRow]]);

//}
//-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
//		if ([self.commandContent.allValues containsObject:item]){
//			return self.commandContent.allValues[index] == NSNull.null ? nil : [
//		}
//		else {
//			[self.commandContent ]
//}
//- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
//
//}
//- (NSUInteger) outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
//{}
//- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
//
//}
//
//		NSString *last  = [txt substringFromIndex:txt.length -1];
//		id x = [context[context] toObject];
//		NSLog(@"%@", context[x][@"keys"]);//txt:%@.. EXE:%@",txt, exe ? @"EXE" : @"NO WAIT!");
//		[context evaluateScript:txt];
//


// _view.enclosingScrollView.backgroundColor = NSColor.redColor;
//_view.enclosingScrollView.drawsBackground = YES;
//	   _view.autoresizingMask		= NSViewNotSizable;
//		 _view.backgroundColor = NSColor.clearColor;
//	[[_window.contentView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		[(NSView*)obj setAutoresizingMask:NSViewWidthSizable| NSViewHeightSizable];
//	}];
//	void(^fixWindow)() = ^{ NSRect windowRect = [_window.contentView bounds];
//		windowRect.size.height /= 2;											[[_window.contentView subviews][0] setFrame:windowRect];
//		windowRect.origin.y		 += windowRect.size.height;	[[_window.contentView subviews][1] setFrame:windowRect];
//	};
//	OBSERVE(NSWindowDidResizeNotification, fixWindow(););

//
//		NSLog(@"last:%@", last);
//		if (![last isEqualToString:@";"]) return;
//
//		NSArray *lines	= [txt componentsSeparatedByString:@";"];
//		//	NSArray *last  = [lines.lastObject componentsSeparatedByString:@";"];
//		NSInteger loc = [lines.lastObject rangeOfString:@"_"].location;
//		BOOL has_ = loc != NSNotFound;
//		NSLog(@"location: %ld", loc);
//		NSString *todo = has_ ? txt : ^{
//				NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,lines.count -2)];
//				NSArray *base = [lines objectsAtIndexes:set];
//				base = [base arrayByAddingObject:[@"_ = " stringByAppendingString:lines.lastObject]];
//				return [base componentsJoinedByString:@";"];
//		}();
//
//		NSLog(@"todo:%@",todo);//txt:%@.. EXE:%@",txt, exe ? @"EXE" : @"NO WAIT!");
//	 NSRect w = _window.frame; w.size.width += 3; [_window setFrame:w display:YES];
//	JSContext* ctx = JSContext.new;
//	[ctx evaluateScript:@"console.log(\"Hello JavaScript\")"]; 

//	NSLog(@"%@",[self.commandContent valueForKey:@"representedObject"]);
//	[_commands					 bind:@"content" toObject:self      withKeyPath:@"commandContent"										 options:nil];
//	[_ov.tableColumns[0] bind:@"value"   toObject:_commands withKeyPath:@"arrangedObjects.representedObject" options:nil];
//	[_ov reloadData];



//- (void) setEvalString:		    (NSString*)evalString		{	//	This is the "keyPath" that "Affects" ResultString.
// } //	Aka you change this.. and KVO updates the dependent (readonly) resultstring.
																												//		NSString *res = ;	NSLog(@"got res: %@", res);	[self appendString:[@"_ = " stringByAppendingString:res] toView:_result];
