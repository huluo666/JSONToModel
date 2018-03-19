//
//  ViewController.m
//  JSONToModel
//
//  Created by luo.h on 2018/3/14.
//  Copyright © 2018年 hl.com.cn. All rights reserved.
//

#import "ViewController.h"
#import "JSONToModel-Swift.h"

#import "AFNetClient.h"
#import "NSDictionary+JSON.h"
#import "MJExtension.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "HighlightingTextStorage.h"

@interface  ViewController()

@property(nonatomic,strong) NSMutableArray *arrayModel;
@property(nonatomic,strong) NSMutableArray *arrayDictModel;
@property(nonatomic,strong) NSDictionary *jsonDict;
@property(nonatomic,copy) NSMutableString* classString;        //存类头文件内容

@end

@implementation ViewController


#define RGB(a,b,c)  [NSColor colorWithRed:(a/255.0) green:(b/255.0) blue:(c/255.0) alpha:1.00]
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.inputTextView lnv_setUpLineNumberView];
    [self.outPutTextView lnv_setUpLineNumberView];
    
    self.inputTextView.font=[NSFont fontWithName:@"Menlo" size:13];
    self.inputTextView.backgroundColor=[NSColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.00];
    self.outPutTextView.backgroundColor=RGB(40, 43, 53);
    self.outPutTextView.font=[NSFont systemFontOfSize:14];
    
    self.outPutTextView.automaticDashSubstitutionEnabled = NO;
    self.outPutTextView.automaticTextReplacementEnabled = NO;
    self.outPutTextView.automaticQuoteSubstitutionEnabled = NO;
    self.outPutTextView.enabledTextCheckingTypes = 0;
    
    [self.outPutTextView setEnabledTextCheckingTypes:NSTextCheckingTypeLink];
    [self.outPutTextView setAutomaticLinkDetectionEnabled:YES];
    
    //光标颜色
    self.outPutTextView.insertionPointColor=[NSColor whiteColor];
    //Replace text storage
    HighlightingTextStorage *textStorage = [[HighlightingTextStorage alloc]init];
    textStorage.defaultTextColor=[NSColor whiteColor];
    [textStorage addLayoutManager:self.outPutTextView.layoutManager];
    
    
    HighlightingTextStorage *textStorage2 = [[HighlightingTextStorage alloc]init];
    textStorage2.language=@"json";
    [textStorage2 addLayoutManager:self.inputTextView.layoutManager];
}


- (IBAction)autoCodeCreate:(id)sender {
    
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    NSString *jsonStr = self.inputTextView.textStorage.string;
    //json字符串转json字典,可用
    NSDictionary *JSONDict = [jsonStr mj_JSONObject];
    self.vildJSONLabel.stringValue = @"已验证";
    if(JSONDict==nil){
        NSLog(@"JSON格式错误，尝试去空格");
        NSString *nonSpaceStr=[NSString removeAllSpace:jsonStr];
        NSLog(@"nonSpaceSt=%@",nonSpaceStr);
        JSONDict= [nonSpaceStr mj_JSONObject];
    }
    
    if(JSONDict==nil){
        self.vildJSONLabel.stringValue = @"JSON格式错误";
        self.vildJSONLabel.textColor=[NSColor redColor];
        return;
    }
    
    self.vildJSONLabel.textColor=[NSColor greenColor];
    [self handleJSON:JSONDict];
    
    CFAbsoluteTime executionTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"executionTime %f ms", executionTime *1000.0);
}



-(void)handleJSON:(NSDictionary *)dic
{
    self.jsonDict=dic;
    _classString = [NSMutableString new];
    NSString *fileStr=[self autoCodeWithJsonDict:dic modelKey:nil];
    NSLog(@"%@", fileStr);
    
    NSMutableString *modelCodeStr=[NSMutableString string];
    [modelCodeStr appendString:fileStr];
    [modelCodeStr appendString:_classString];
    self.outPutTextView.string=modelCodeStr;
    
    [self.outPutTextView lnv_updateLineNumber];
}





-(NSString *)autoCodeWithJsonDict:(NSDictionary *)dic modelKey:(NSString *)classKey
{
    if (classKey.length==0||classKey==nil) {
        classKey=@"<#RootModel#>";
    }
    if ([dic isKindOfClass:[NSDictionary class]]==NO) {
        return @"";
    }
    NSArray *keyArray = [dic allKeys];
    if (keyArray.count==0) return @"";
    
    NSString *fileStr=[NSString stringWithFormat:@"@interface %@ : NSObject \r\n\n",classKey];
    for(int i=0;i<keyArray.count;i++)
    {
        NSString *key = [keyArray objectAtIndex:i];
        NSLog(@"%@", key);
        id value = [dic objectForKey:key];
        if([value isKindOfClass:[NSString class]])
        {
            NSLog(@"string");
            fileStr = [NSString stringWithFormat:@"%@@property (nonatomic, copy)   NSString *%@;\r\n",fileStr,key];
        }
        else if([value isKindOfClass:[NSNumber class]])
        {
            NSLog(@"int");
            fileStr = [NSString stringWithFormat:@"%@@property (nonatomic, assign) NSInteger %@;\r\n",fileStr,key];
        }
        else if([value isKindOfClass:[NSArray class]])
        {
            NSLog(@"array");
            fileStr = [NSString stringWithFormat:@"%@@property (nonatomic, strong) NSArray *%@;\r\n",fileStr,key];
            //判断是否为字典数组
            id subvalue=[value lastObject];
            if ([subvalue isKindOfClass:[NSDictionary class]]) {
                NSString *subArrayStr= [self autoCodeWithJsonDict:subvalue modelKey:key];
                [_classString appendString:subArrayStr];
            }
        }else if([value isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"NSDictionary==%@",value);
            fileStr = [NSString stringWithFormat:@"%@@property (nonatomic, strong) %@ *%@;\r\n",fileStr,key,key];
            NSString *classContent= [self autoCodeWithJsonDict:value modelKey:key];
            [_classString appendString:classContent];
        }else if ([value isKindOfClass:NSClassFromString(@"__NSCFBoolean")]) { // BOOL
            
        }else
        {
            NSLog(@"string");
            fileStr = [NSString stringWithFormat:@"%@@property (nonatomic, strong) NSString *%@;\r\n",fileStr,key];
        }
    }
    fileStr = [fileStr stringByAppendingString:@"\n@end\n\n"];
    return fileStr;
}



- (NSMutableArray *)arrayModel {
    if(_arrayModel == nil) {
        _arrayModel = [[NSMutableArray alloc] init];
    }
    return _arrayModel;
}

- (NSMutableArray *)arrayDictModel {
    if(_arrayDictModel == nil) {
        _arrayDictModel = [[NSMutableArray alloc] init];
    }
    return _arrayDictModel;
}

- (IBAction)goHttpAction:(id)sender {
    if (self.urlTextField.stringValue.length<5) return;
    
    __weak typeof(self)weakSelf = self;
    [AFNetClient GET_Path:self.urlTextField.stringValue completed:^(NSHTTPURLResponse *response, NSDictionary *JSONDict) {
        if (JSONDict.count>0) {
            NSString *json=[JSONDict toReadableJSONString];
            weakSelf.inputTextView.string=json;
            [weakSelf handleJSON:JSONDict];
        }
    } failed:^(NSError *error) {
        NSLog(@"error=%@",error);
    }];
}

@end
