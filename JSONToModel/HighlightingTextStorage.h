//
//  PCHighlightingTextStorage.h
//  JSON_Model
//
//  Created by luo.h on 2018/3/14.
//  Copyright © 2018年 meet.com.cn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,HighlightType) {
    HighlightType_None,
    HighlightType_OC,
    HighlightType_JSON,
    HighlightType_Auto
};


@interface HighlightingTextStorage : NSTextStorage

@property(nonatomic,assign) NSString *language;
@property(nonatomic,strong) NSColor  *defaultTextColor;

@end
