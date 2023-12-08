//
//  LoginYoutubeWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface LoginYoutubeWindowController : NSWindowController
{
    WebView *loginWebView;
}

@property WebView *loginWebView; // @synthesize loginWebView;
- (void)webView:(id)arg1 decidePolicyForNavigationAction:(id)arg2 request:(id)arg3 frame:(id)arg4 decisionListener:(id)arg5;
- (void)webView:(id)arg1 didCommitLoadForFrame:(id)arg2;
- (void)windowDidLoad;

@end
