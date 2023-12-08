//
//  AboutWindowController.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "AboutWindowController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActivationInfo) name:@"ActivationInfoDidChange" object:nil];
    
    [self.window setTitle:NSLocalizedString(@"aboutWindowTitle", nil)];
    [self updateActivationInfo];
}

- (void)updateActivationInfo { 
    ;
}

- (id)initWithWindow:(NSWindow *)window { 
    if (self = [super initWithWindow:window]) {
        [self.window setAlphaValue:1.0];
        [self.window setOpaque:NO];
    }
    return self;
}

@end
