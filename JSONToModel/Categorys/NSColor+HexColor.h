//
//  NSColor+HexColor.h
//  JSONToModel
//
//  Created by luo.h on 2018/3/15.
//  Copyright © 2018年 hl.com.cn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (HexColor)
+ (NSColor *) colorFromHexCode:(NSString *)hexString;
@end
