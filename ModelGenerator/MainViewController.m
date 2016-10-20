//
//  MainViewController.m
//  ModelGenerator
//
//  Created by zhubch on 15/8/11.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MainViewController.h"
#import "ModelGenerator.h"
#import "ClassViewController.h"

@interface MainViewController ()<ClassViewControllerDelegate,NSComboBoxDataSource,NSTextViewDelegate>

/// api to oc property use
@property (nonatomic) NSString *rightCodeString;

@property (weak) IBOutlet NSButton *emptyBtn;
@end

@implementation MainViewController
{
    ModelGenerator *generater;
    id objectToResolve;
    NSString *result;
    NSArray *languageArray;
}
#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(700, 400);
    
    languageArray = @[@"Objective-C",@"Swift",@"Java", @"Api to OC property", @"Sosoapi to OC property", @"Sosoapi to OC dict", @"Sosoapi to postman bulk edit"];
    generater = [ModelGenerator sharedGenerator];
    
    [_jsonTextView becomeFirstResponder];
    

    _comboBox.placeholderAttributedString = [self btnAttributedStringWithtitle:@"Language"];
    _classNameField.placeholderAttributedString = [self btnAttributedStringWithtitle:@"ClassName"];
    _startBtn.attributedTitle = [self btnAttributedStringWithtitle:@"Start"];
    self.emptyBtn.attributedTitle = [self btnAttributedStringWithtitle:@"empty"];
    _comboBox.stringValue = @"Objective-C";
    generater.language = ObjectiveC;
    [self makeRound:_comboBox];
    [self makeRound:_classNameField];
    [self makeRound:_startBtn];
    [self makeRound:self.emptyBtn];
}

#pragma mark - action
#pragma mark empty btn
- (IBAction)clickemptyBtn:(NSButton *)sender {
    self.jsonTextView.string = @"";

}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
#pragma mark start btn
- (IBAction)generate:(id)sender {

    if (self.comboBox.indexOfSelectedItem >= languageArray.count) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"请先选择一个转换格式";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
        return;
    }
    
    NSString *currentLanguage = languageArray[self.comboBox.indexOfSelectedItem];
    if ([currentLanguage isEqualToString:@"Objective-C"]) {
        [self jsonToOCProperty];
    } else if ([currentLanguage isEqualToString:@"Swift"]) {
        [self jsonToOCProperty];

    } else if ([currentLanguage isEqualToString:@"Java-C"]) {
        [self jsonToOCProperty];

    } else if ([currentLanguage isEqualToString:@"Api to OC property"]) {
        [self apiToOCProperty];
    } else if ([currentLanguage isEqualToString:@"Sosoapi to OC property"]) {
        [self sosoapiToOCProperty:YES needOCDict:NO];
    } else if ([currentLanguage isEqualToString:@"Sosoapi to OC dict"])  {
        [self sosoapiToOCProperty:YES needOCDict:YES];
    }
    else if ([currentLanguage isEqualToString:@"Sosoapi to postman bulk edit"]) {
        [self sosoapiToOCProperty:NO  needOCDict:NO];
    }
    
}
#pragma mark jsonToOCProperty
- (void)jsonToOCProperty {
    if (self.jsonTextView.textStorage.string.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"请先输入要转换的Json文本";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    if (_classNameField.stringValue.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"请输入要生成的类名";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    if (generater.language == Unknow) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"请选择语言";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    generater.className = _classNameField.stringValue;
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[_jsonTextView.textStorage.string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"无效的Json数据";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
    dispatch_async(dispatch_queue_create("generate", DISPATCH_QUEUE_CONCURRENT), ^{
        NSString *code = [generater generateModelFromDictionary:dic withBlock:^NSString *(id unresolvedObject) {
            
            objectToResolve = unresolvedObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"showModal" sender:self];
            });
            result = nil;
            
            while (result == nil) {
                sleep(0.1);
            }
            return result;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.codeTextView insertText:code replacementRange:NSMakeRange(0, 1)];
            self.codeTextView.editable = NO;
        });
        
    });

}
#pragma mark apiToOCProperty
- (void)apiToOCProperty {
    
    if (self.jsonTextView.textStorage.string.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"无码不欢";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    
    NSString *inputString = _jsonTextView.textStorage.string;
    NSArray *lineCodeStrings =
    [inputString componentsSeparatedByString:@"\n"];
    
    NSMutableArray <NSString *> *temArr = @[].mutableCopy;
    
    [lineCodeStrings enumerateObjectsUsingBlock:^(NSString  *_Nonnull lineCodeString, NSUInteger idx, BOOL * _Nonnull stop) {
        // lineCodeString ->  title           string      标题,
        NSMutableArray <NSString *>*arr = [lineCodeString.mutableCopy componentsSeparatedByString:@" "].mutableCopy;
        [self dealWithArray:arr];
        if (arr.count == 3) {
            NSString *propertyName = arr.firstObject;
            NSString *className = arr[1];
            NSString *descString = arr[2];
            NSString *objectStr = @"*";
            
            if ([className isEqualToString:@"string"]) {
                className = @"NSString";
            } else if ([className isEqualToString:@"int"]) {
                className = @"NSInteger";
            } else if ([className isEqualToString:@"array"]) {
                className = @"NSArray";
            }
            if ([className isEqualToString:@"NSInteger"]) {
                objectStr = @" ";
            } else if ([className isEqualToString:@"NSString"]) {
                objectStr = @"  *";
            } else if ([className isEqualToString:@"NSArray"]) {
                objectStr = @"   *";
            }
            NSString *codeString = [NSString stringWithFormat:@"///  %@\n@property (nonatomic) %@%@%@;\n\n", descString, className, objectStr, propertyName];
            [temArr addObject:codeString];
            
            NSLog(@"----%@---", codeString);
        }
        
        
    }];
    
    self.rightCodeString = [temArr componentsJoinedByString:@""];
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.codeTextView insertText:self.rightCodeString replacementRange:NSMakeRange(0, 1)];
        self.codeTextView.editable = NO;
    });

}
/// 如果是OCProperty 就生成oc property code ,otherwise postman bulk edit
- (void)sosoapiToOCProperty:(BOOL)isOCProperty needOCDict:(BOOL)isNeedDict{
    
    
    if (self.jsonTextView.textStorage.string.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"无码不欢";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    
    NSString *inputString = _jsonTextView.textStorage.string;
    NSMutableArray <NSString *>*lineCodeStrings =
    [inputString componentsSeparatedByString:@"\n"].mutableCopy;
    
    
    [self dealWithArray:lineCodeStrings];
    
    
    NSMutableArray *arrs = @[].mutableCopy;
    for (NSInteger i = 0; i < [lineCodeStrings count] ; i ++) {
        
        NSMutableArray *arr1 = [NSMutableArray array];
        NSInteger counts = 0;
        
        while (counts != 3 && i < [lineCodeStrings count]  ) {
            counts++;
            [arr1 addObject:lineCodeStrings[i]];
            i ++;
            
            
        }
        [arrs addObject:arr1];
        
        i --;
    }
    
    NSMutableArray *outPutArray = @[].mutableCopy;
    [arrs enumerateObjectsUsingBlock:^(NSArray<NSString *>  *_Nonnull lineArray, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (lineArray.count == 3) {
            
            
            NSString *propertyName = lineArray.firstObject;
            NSString *descString = [lineArray[1].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""];
            NSString *className = lineArray[2];
            NSString *objectStr = @"*";
            
            if ([className isEqualToString:@"string"]) {
                className = @"NSString";
            } else if ([className isEqualToString:@"integer"]) {
                className = @"NSInteger";
            } else if ([className isEqualToString:@"array"]) {
                className = @"NSArray";
            }
            if ([className isEqualToString:@"NSInteger"]) {
                objectStr = @" ";
            } else if ([className isEqualToString:@"NSString"]) {
                objectStr = @"  *";
            } else if ([className isEqualToString:@"NSArray"]) {
                objectStr = @"   *";
            }            
            
            NSString *codeString = @"??";
            if (!isOCProperty) {
                
                    
                    codeString = [NSString stringWithFormat:@"%@:1\n", propertyName];
                

                
            } else  {
                if (isNeedDict) {
                    
                    /*
                     @{
                     @"":@"",
                     @"":@"",
                     @"":@"",
                     
                     @"":@""}
                     
                     */
                    if (idx == 0) {
                        
                        codeString = [NSString stringWithFormat:@"@{\n\t@\"%@\": @1,\n", propertyName];

                    } else if (idx == arrs.count -1) {
                        
                        codeString = [NSString stringWithFormat:@"\t@\"%@\": @1 \n  }", propertyName];

                    } else {
                        
                        codeString = [NSString stringWithFormat:@"\t@\"%@\": @1,\n", propertyName];
                    }
                    
                    
                } else {
                    
                    codeString = [NSString stringWithFormat:@"///  %@\n@property (nonatomic) %@%@%@;\n\n", descString, className, objectStr, propertyName];
                }
            }
            [outPutArray addObject:codeString];
        }
        
        
    }];

    self.rightCodeString = [outPutArray componentsJoinedByString:@""];
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.codeTextView insertText:self.rightCodeString replacementRange:NSMakeRange(0, 1)];
        self.codeTextView.editable = NO;
    });

}
#pragma mark - selected a language
- (IBAction)selectedLanguage:(NSComboBox*)sender {
    if (sender.indexOfSelectedItem < languageArray.count) {
        generater.language = sender.indexOfSelectedItem;
        
        BOOL showJsonPlaceHoler = sender.indexOfSelectedItem <= 2;
        self.placeHolder.placeholderString =  showJsonPlaceHoler ? @"请输入Json文本" : @"请输入api文本";
        self.classNameField.hidden = !showJsonPlaceHoler;
    }
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showModal"]) {
        ClassViewController *vc = segue.destinationController;
        vc.objectToResolve = objectToResolve;
        vc.delegate = self;
    }
}

#pragma mark NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(nullable NSArray<NSString *> *)replacementStrings{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _placeHolder.hidden = textView.textStorage.string.length > 0;
    });
    return YES;
}

#pragma mark ClassViewControllerDelegate

- (void)didResolvedWithClassName:(NSString *)name
{
    if (generater.language == ObjectiveC && ![name hasSuffix:@"*"]) {
        name = [name stringByAppendingString:@"*"];
    }
    result = name;
//    NSLog(@"%@",result);
}

#pragma mark NSComboBoxDelegate & NSComboBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return languageArray.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return languageArray[index];
}
#pragma mark - private 
- (NSAttributedString *)btnAttributedStringWithtitle:(NSString *)title  {
    return [[NSAttributedString alloc]initWithString:title attributes:@{NSFontAttributeName: [NSFont fontWithName:@"Times New Roman" size:16],NSForegroundColorAttributeName:[NSColor whiteColor]}];
}
- (void)makeRound:(NSView*)view{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 10;
    view.layer.borderWidth = 5;
    view.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (void)dealWithArray:(NSMutableArray *)arr {
    [arr enumerateObjectsUsingBlock:^(NSString  *_Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([str isEqualToString:@" "] || [str isEqualToString:@"formData"]) {
            [arr removeObject:str];
        }
        BOOL hasValue = str && str.length;
        if (!hasValue) {
            [arr removeObject:str];
        }
        
    }];
}

@end
