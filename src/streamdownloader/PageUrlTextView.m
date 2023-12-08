//
//  PageUrlTextView.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "PageUrlTextView.h"

NSAttributedString* g_attrString = nil;

@implementation PageUrlTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if ([self.string isEqualToString:@""]) {
        if ([self.window firstResponder] != self) {
            [g_attrString drawAtPoint:NSMakePoint(0.0, 0.0)];
        }
    }
}

- (void)mouseDown:(id)arg1 { 
    if ([[self delegate] respondsToSelector:@selector(mouseDownOnTextField:)]) {
        [[self delegate] mouseDownOnTextField:self];
    }
}

- (BOOL)resignFirstResponder { 
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder { 
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}

- (void)setPlaceholderString:(NSString*)placeholder {
    [self setString:placeholder];
    [self setTextColor:[NSColor lightGrayColor]];
    [self setSelectedRange:NSMakeRange(0, 0)];
}

- (void)enableTextView:(BOOL)bEnable { 
    [self setSelectable:bEnable];
    [self setEditable:bEnable];
    if (bEnable) {
        [self setTextColor:[NSColor controlTextColor]];
    }
    else {
        [self setTextColor:[NSColor disabledControlTextColor]];
    }
}

- (BOOL)isEnabled {
    BOOL bRet = YES;
    if (![self isEditable] || ![self isSelectable]) {
        bRet = NO;
    }
    return bRet;
}

- (void)doCommandBySelector:(SEL)sel { 
    if ([self isEnabled]) {
        if (@selector(insertNewline:) == sel) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PressEnterInTextView" object:self];
        }
        else {
            if (@selector(cancelOperation:) != sel) {
                if (@selector(deleteBackward:) == sel) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PressBackspace" object:self];
                    [NSApp sendAction:sel to:self.window.firstResponder from:self];
                }
                else {
                    if ([self.window.firstResponder respondsToSelector:sel]) {
                        [NSApp sendAction:sel to:self.window.firstResponder from:self];
                    }
                }
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PressEscape" object:self];
        }
    }
}

- (void)paste:(id)arg1 {
    NSPasteboard* pasteBoard = [NSPasteboard generalPasteboard];
    [self readSelectionFromPasteboard:pasteBoard];
    NSParagraphStyle* paragraph = [NSParagraphStyle defaultParagraphStyle];
    [paragraph.mutableCopy setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [self.textStorage addAttribute:NSParagraphStyleAttributeName value:paragraph.mutableCopy range:NSMakeRange(0, self.textStorage.length)];
    
    NSCharacterSet* charSet = [NSCharacterSet newlineCharacterSet];
    id urls = [self.textStorage.string componentsSeparatedByCharactersInSet:charSet];
    id urls_with_space = [urls componentsJoinedByString:@" "];
    [self setString:urls_with_space];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PasteInTextView" object:self];
}

- (void)awakeFromNib { 
    [self.textContainer setContainerSize:NSMakeSize(3.402823466385289e38, 3.402823466385289e38)];
    [self.textContainer setWidthTracksTextView:YES];
    [self.textContainer setHeightTracksTextView:NO];
    [self setTextContainer:self.textContainer];
    [self setAutoresizingMask:NSViewNotSizable];
    [self setMaxSize:NSMakeSize(3.402823466385289e38, 3.402823466385289e38)];
}

- (void)initializePlaceholder { 
    NSColor* lightGray = [NSColor lightGrayColor];
    NSFont* systemFont = [NSFont systemFontOfSize:14.0];
    
    NSDictionary* dict = @{NSForegroundColorAttributeName: lightGray, NSFontAttributeName: systemFont};
    g_attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"placeholderVideoUrl", nil) attributes:dict];
}

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        return self;
    }
    return nil;
}

@end
