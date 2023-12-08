//
//  LoginYoutubeWindowController.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "LoginYoutubeWindowController.h"
#import "YoutubeDownloaderAppDelegate.h"

@interface LoginYoutubeWindowController ()

@end

@implementation LoginYoutubeWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.loginWebView setFrameLoadDelegate:self];
    WebFrameView* loginView = [[self.loginWebView mainFrame] frameView];
    [loginView setAllowsScrolling:NO];
    
    NSURL* googleUrl = [NSURL URLWithString:@"https://accounts.google.com/ServiceLogin?continue=https://www.youtube.com/signin?action_handle_signin=true&feature=sign_in_button&hl=en_US&nomobiletemp=1"];
    
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:googleUrl];
    [[self.loginWebView mainFrame] loadRequest:urlRequest];
    [self.window center];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    id typeKey = [frame valueForKey:WebActionNavigationTypeKey];
    if ([typeKey integerValue]) {
        [listener use];
    }
    
    id urlKey = [actionInformation valueForKey:WebActionOriginalURLKey];
    if (!urlKey) {
        urlKey = [request URL];
    }
    NSString* lastComponent = [urlKey lastPathComponent];
    
    if ([lastComponent isEqualToString:@"ServiceLogin"]) {
        [listener use];
    }
    else {
        [listener ignore];
    }
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
    WebFrameView* loginView = [[self.loginWebView mainFrame] frameView];
    [loginView setAllowsScrolling:NO];
    NSMutableString* urlString = [[NSMutableString alloc] initWithString:[sender mainFrameURL]];
    
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSURL* loginUrl = [NSURL URLWithString:urlString];
    id cookies = [cookieStorage cookiesForURL:loginUrl];
    
    NSMutableString* tmpString = [NSMutableString stringWithString:@""];
    
    for (NSHTTPCookie * each in cookies) {
        NSString* domain = [each domain];
        NSRange searchRange = [domain rangeOfString:@"youtube.com"];
        if (searchRange.location != NSNotFound) {
            NSString* nameValue = [NSString stringWithFormat:@"%@=%@;", each.name, each.value];
            [tmpString appendString:nameValue];
        }
    }
    
    if (tmpString.length) {
        NSRange searchRange = [tmpString rangeOfString:@"LOGIN_INFO"];
        if (searchRange.location != NSNotFound) {
            YoutubeDownloaderAppDelegate* delegate = [NSApp delegate];
            NSString* cookie = [NSString stringWithString:tmpString];
            [delegate setCookies:cookie];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.window performClose:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SetValueNeedSignIn" object:nil];
            });
        }
    }
}

@end
