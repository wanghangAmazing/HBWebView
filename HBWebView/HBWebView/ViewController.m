//
//  ViewController.m
//  HBWebView
//
//  Created by Patrick W on 2017/9/5.
//  Copyright © 2017年 Original. All rights reserved.
//

#import "ViewController.h"
#import "HBWebViewController.h"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (IBAction)loadWebView:(UIButton *)sender {
    HBWebViewController *webview = [[HBWebViewController alloc] init];
    webview.address = @"https://www.baidu.com";
    webview.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webview animated:YES];
}

- (IBAction)loadLocalHtml:(UIButton *)sender {
    HBWebViewController *webview = [[HBWebViewController alloc] init];
    webview.hidesBottomBarWhenPushed = YES;
    webview.localHtmlName = @"local";
    [self.navigationController pushViewController:webview animated:YES];
}


@end
