//
//  MouseDownTextFieldDelegateProtocol.h
//  streamdownloader
//
//  Created by ted zhang on 2018/5/20.
//  Copyright © 2018年 firefury. All rights reserved.
//

#ifndef MouseDownTextFieldDelegateProtocol_h
#define MouseDownTextFieldDelegateProtocol_h

#import <Cocoa/Cocoa.h>

@protocol MouseDownTextFieldDelegate <NSTextFieldDelegate>
- (void)mouseDownOnTextField:(NSTextView *)arg1;
@end


#endif /* MouseDownTextFieldDelegateProtocol_h */
