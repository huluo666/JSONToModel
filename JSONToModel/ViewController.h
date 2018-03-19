//
//  ViewController.h
//  JSONToModel
//
//  Created by luo.h on 2018/3/14.
//  Copyright © 2018年 hl.com.cn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *outPutTextView;
- (IBAction)autoCodeCreate:(id)sender;
@property (weak) IBOutlet NSTextField *vildJSONLabel;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *goHttpButton;

- (IBAction)goHttpAction:(id)sender;

@end

