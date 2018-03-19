//
//  PCHighlightingTextStorage.m
//  JSON_Model
//
//  Created by luo.h on 2018/3/14.
//  Copyright © 2018年 meet.com.cn. All rights reserved.
//

#import "HighlightingTextStorage.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSDictionary+JSON.h"
#import "NSColor+HexColor.h"

@interface HighlightingTextStorage()

@property(nonatomic,strong) JSContext *context;

@end

@implementation HighlightingTextStorage
{
    NSMutableAttributedString *_imp;
    NSDictionary  *_replacements;
    NSDictionary  *_CSSDict;

}

// 设置高亮正则表达式
static NSString *const kUserPattern = @"\\@\\w+"; // "@用户名 @interface"
static NSString *const kNSClassPattern = @"\\b((NS|UI|CG)\\w+?)"; // "NSxxx"
static NSString *const kTopicPattern = @"\\#\\w+\\#"; // "#话题#"
static NSString *const kEmotionPattern = @"\\[\\w+\\]"; // "[]"表情
#define REGEX_STRING        @"\".*?\"" //字符串
#define REGEX_KEY           @"\".*?\" :" //键值对中的key
#define REGEX_VALUE         @"(?<=: )\".*?\"" //键值对中的value
#define REGEX_BRACES        @"\\{|\\}" //大括号
#define REGEX_BRACKETS      @"\\[|\\]" //中括号
#define REGEX_NUM           @"\\d+"    //键值对中的value
#define REGEX_URL    @"(((ht|f)tp(s?))\\://)?(www.|[a-zA-Z].)[a-zA-Z0-9\\-\\.]+\\.(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\;\\?\\'\\\\\\+&%\\$#\\=~_\\-]+))*"; // URL 过滤
#define RGB(a,b,c)  [NSColor colorWithRed:(a/255.0) green:(b/255.0) blue:(c/255.0) alpha:1.00]

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imp = [[NSMutableAttributedString alloc] init];
        [self configHighlightPatterns];
        [self setUpContext];
        _CSSDict=kThemeInfo();
    }
    return self;
}

#pragma mark - Reading Text
- (NSString *)string
{
    return _imp.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_imp attributesAtIndex:location effectiveRange:range];
}

#pragma mark - Text Editing
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    if (str) {
        [self beginEditing];
        [_imp replaceCharactersInRange:range withString:str];
        [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
        [self endEditing];
    }
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{    
    [self beginEditing];
    [_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}


- (void)fixAttributesInRange:(NSRange)range {
    [self performReplacementsForRange:range];
    [super fixAttributesInRange:(NSRange)range];
}

#pragma mark - Syntax highlighting
- (void)performReplacementsForRange:(NSRange)changedRange {
    //默认是黑色--这里设置白色-Menlo字体
    NSLog(@"foregroundColor=%@",self.foregroundColor);
    if (self.defaultTextColor) {
        NSDictionary *atts=@{NSFontAttributeName :[NSFont fontWithName:@"Menlo" size:14],NSForegroundColorAttributeName:self.defaultTextColor};
        [self addAttributes:atts range:changedRange];
    }
    
    
    NSString *language=[self.language lowercaseString];
    NSRange paragaphRange = [self.string paragraphRangeForRange:self.editedRange];
    __weak typeof(self)weakSelf = self;
    if ([language isEqualToString:@"objectivec"]) {
        for (NSString* key in _replacements) {
            NSDictionary* attributes = _replacements[key];
            [RegexWithPattern(key) enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                [weakSelf addAttributes:attributes range:result.range];
            }];
        }
    }else if ([language isEqualToString:@"json"]){
        //数字高亮
        [RegexWithPattern(REGEX_NUM) enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            // Add red highlight color
            [weakSelf addAttribute:NSForegroundColorAttributeName value:RGB(194, 53, 154) range:result.range];
        }];
        
        //value高亮
        [RegexWithPattern(REGEX_VALUE) enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            // Add red highlight color
            [weakSelf addAttribute:NSForegroundColorAttributeName value:RGB(221,18,67) range:result.range];
        }];
    }else{
        [self highligtCodeForRange:paragaphRange];
    }
}

- (void)configHighlightPatterns{
    //属性 @name
    NSString *keyWordsRegex = [NSString stringWithFormat:@"%@|nonatomic|strong|copy|assign",kUserPattern];
    //NSString、NSArray、NSDictionary...NS
    NSString *regex_NS = [NSString stringWithFormat:@"%@",kNSClassPattern];
    _replacements = @{
                     keyWordsRegex :AttributesWithColor(RGB(194, 53, 154)),
                     regex_NS : AttributesWithColor(RGB(0,175,202))
                     };
}


#pragma mark--使用JavaScript库渲染
- (void)highligtCodeForRange:(NSRange)paragaphRange
{
    NSString *content=[self.string substringWithRange:paragaphRange];
    //    #Fix JS Exception: SyntaxError: Unexpected EOF
//    NSString  *command= [NSString stringWithFormat:@"window.hljs.highlightAuto(\"%@\").value;",escapeContent(content)];
    NSString  *command = [NSString stringWithFormat:@"window.hljs.highlight(\"%@\",\"%@\").value;",@"objectivec",escapeContent(content)];
    NSString *highlightString = [[self.context evaluateScript:command] toString];
    NSLog(@"highlight:%@",highlightString);
    [self renderContent:highlightString withRange:paragaphRange];
}




static NSDictionary * kThemeInfo() {
    static NSDictionary *_themeInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        // 获取文件路径
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"xcodetheme" ofType:@"json"];
        // 根据文件路径读取数据
        NSData *jdata = [[NSData alloc] initWithContentsOfFile:filePath];
        // 格式化成json数据
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
        NSLog(@"jsonObject=%@",jsonObject);
        _themeInfo=jsonObject;
    });
    return _themeInfo;
}



-(void)setUpContext
{
    JSContext *context=[[JSContext alloc]init];
    [context evaluateScript:@"var window = {};"];
     context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"# JS Exception: %@", exception);
        context.exception = exception;
    };
    self.context=context;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"highlight.min"  ofType:@"js"];
    NSString *js = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    JSValue  *value=  [self.context evaluateScript:js];
    if ([value toBool]==NO) {
        NSLog(@"初始化失败");
    }else{
        NSLog(@"初始化成功");
    }
}


-(void)renderContent:(NSString *)content withRange:(NSRange)paragaphRange
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<span class=\"([A-Za-z-_]*)\">(.*?)<\\/span>" options:NSRegularExpressionCaseInsensitive error:nil];
    if (content.length>0) {
        //匹配第一个
        NSArray *results = [regex matchesInString:content options:NSMatchingReportProgress range:NSMakeRange(0, [content length])];
        for (NSTextCheckingResult *result in results) {
            NSString *className= [content substringWithRange:[result rangeAtIndex:1]];
            NSRange wordRange=[result rangeAtIndex:2];
            NSString *word= [content substringWithRange:wordRange];
            NSDictionary *attributs=[NSDictionary dictionary];
            NSString *subKey = findKey(className, _CSSDict);
            NSDictionary *atts=_CSSDict[subKey];
            NSString *color_hex=atts[@"color"];
            if (color_hex.length>0) {
//                NSLog(@"高亮：%@=%@=%@-%@",word,className,subKey,color_hex);
                attributs=AttributesWithColor([NSColor colorFromHexCode:color_hex]);
            }
            [RegexWithPattern(word) enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                //高亮关键词
                [self addAttributes:attributs range:result.range];
            }];
        }
    }
}


#pragma mark---内联函数--
static inline NSString *escapeContent(NSString *content) {
    NSString *html =content;
    html = [html stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return html;
}

static inline NSDictionary  *AttributesWithColor(NSColor *color) {
    return @{NSFontAttributeName :[NSFont fontWithName:@"Menlo" size:14],NSForegroundColorAttributeName:color};
}

static inline NSRegularExpression *RegexWithPattern(NSString *pattern) {
    return [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
}

static inline NSString  *findKey(NSString *subKey,NSDictionary *dict) {
    NSArray *keys = [dict allKeys];
    for(NSString *key in keys){
        if([key containsString:subKey]){
            return key;
        }
    }
    return nil;
}

@end
