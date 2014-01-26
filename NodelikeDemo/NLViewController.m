//
//  NLViewController.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLViewController.h"

@implementation NLViewController

- (void) viewDidLoad	{  [super viewDidLoad];

    _appDelegate = UIApplication.sharedApplication.delegate;
}

- (void) didReceiveMemoryWarning	{ [super didReceiveMemoryWarning]; }

- (IBAction) execute:(id)sender { NSLog(@"execute");

    _state.text = [@"_ = " stringByAppendingString:[_appDelegate execute:_output.text]];
    _output.text = @"";
}

@end
