//
//  PageUrlTextView.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MouseDownTextFieldDelegateProtocol.h"

@interface PageUrlTextView : NSTextView
{
}

@property id <MouseDownTextFieldDelegate> delegate; // @synthesize delegate;
- (void)mouseDown:(id)arg1;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;
- (void)setPlaceholderString:(id)placeholder;
- (void)enableTextView:(BOOL)bEnable;
- (BOOL)isEnabled;
- (void)doCommandBySelector:(SEL)sel;
- (void)paste:(id)arg1;
- (void)drawRect:(NSRect)arg1;
- (void)awakeFromNib;
- (void)initializePlaceholder;
- (id)initWithFrame:(NSRect)arg1;

@end
