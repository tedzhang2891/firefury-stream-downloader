//
//  AboutWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController <NSWindowDelegate>
{

}

@property NSTextField *lblEltimaSign; // @synthesize lblEltimaSign=_lblEltimaSign;
@property NSTextField *txtRegisteredTo; // @synthesize txtRegisteredTo=_txtRegisteredTo;
@property NSTextField *lblRegisteredTo; // @synthesize lblRegisteredTo=_lblRegisteredTo;
@property NSTextField *txtLicenseType; // @synthesize txtLicenseType=_txtLicenseType;
@property NSTextField *lblLicenseType; // @synthesize lblLicenseType=_lblLicenseType;
@property NSTextField *lblVersion; // @synthesize lblVersion=_lblVersion;
@property NSImageView *imgLogo; // @synthesize imgLogo=_imgLogo;
- (void)updateActivationInfo;
- (void)windowDidLoad;
- (id)initWithWindow:(NSWindow*)window;

@end
