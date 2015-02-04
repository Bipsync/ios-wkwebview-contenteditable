//
//  ViewController.m
//  ios-wkwebview-contenteditable
//
//  Created by Craig Marvelley on 04/02/2015.
//  Copyright (c) 2015 Bipsync. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    [configuration.userContentController addScriptMessageHandler:self name:@"editor"];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
    
    [self loadEditorResources];
    
}

- (void)webViewDidLoad {
    
    NSString *javaScript = [self stringEscapedForJavasacript:@"document.getElementById('editor').focus();"];
    
    [_webView evaluateJavaScript:javaScript completionHandler:^(id object, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"%@", object);
        }
    }];
    
}

- (void)loadEditorResources {
    
    NSString *editorHtmlFilePath = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];
    NSString *editorHtml = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:editorHtmlFilePath] encoding:NSUTF8StringEncoding];
    
    [_webView loadHTMLString:editorHtml baseURL:nil];
    
}

- (NSString *)stringEscapedForJavasacript:(NSString *)string {
    
    if (!string) {
        return nil;
    }
    
    // valid JSON object needs to be an array or dictionary
    NSArray *arrayForEncoding = @[string];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:arrayForEncoding options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *escapedString = [jsonString substringWithRange:NSMakeRange(2, jsonString.length - 4)];
    
    return escapedString;
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.body isKindOfClass:[NSString class]]) {
        NSString *body = (NSString *)message.body;
        if ([body isEqualToString:@"loaded"]) {
            [self webViewDidLoad];
        } else {
            NSLog(@"%@", body);
        }
    }
    
}

@end