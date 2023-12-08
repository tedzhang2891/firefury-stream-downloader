//
//  ProcessingLinksWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProcessingLinksWindowController : NSWindowController

@property NSButton *btnCancel; // @synthesize btnCancel;
@property NSProgressIndicator *progressProcessing; // @synthesize progressProcessing;
@property NSTextField *txtAboutProcessing; // @synthesize txtAboutProcessing;
- (void)buttonCancelWasClicked:(id)sender;
- (void)windowDidLoad;
- (id)initWithWindow:(NSWindow *)window;

@end


