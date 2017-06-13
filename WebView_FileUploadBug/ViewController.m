//
//  ViewController.m
//  WebView_FileUploadBug
//
//  Created by YLCHUN on 2017/5/6.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

//typedef WKWebView WebView;
typedef UIWebView WebView;

@interface ViewController ()
@property (nonatomic, retain) WebView *webView;
@end

@implementation ViewController

-(WebView *)webView {
    if (!_webView) {
        _webView = [[WebView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:_webView atIndex:0];
    }
    return _webView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
