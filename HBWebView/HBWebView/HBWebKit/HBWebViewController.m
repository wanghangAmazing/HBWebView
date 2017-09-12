//
//  HBWebViewController.m
//  HBWebView
//
//  Created by Patrick W on 2017/9/11.
//  Copyright © 2017年 Original. All rights reserved.
//

#import "HBWebViewController.h"
#import "HBWebView.h"

@interface HBWebViewController ()

@property (strong, nonatomic) HBWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIButton *navBackButton;
@property (strong, nonatomic) UIButton *navCloseButton;

@end

@implementation HBWebViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavgationBar];
    [self setupSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.webView.frame = self.view.bounds;
    self.progressView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 5);
}

- (void)setupNavgationBar {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.navBackButton];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:self.navCloseButton];
    self.navigationItem.leftBarButtonItems = @[backItem, closeItem];
}

- (void)setupSubviews {
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
    __weak typeof(self) weakSelf = self;
    [self.webView setTitleChangeHandler:^(WKWebView *webview, NSString *newTitle) {
        weakSelf.title = newTitle;
    }];
    
    [self.webView setProgressChangeHandler:^(WKWebView *webview, double progress) {
        [weakSelf.progressView setProgress:progress animated:YES];
    }];
    
    [self.webView setLoadingChangeHandler:^(WKWebView *webview, BOOL loading) {
        if (loading) {
            [weakSelf.progressView setHidden:NO];
        } else {
            [weakSelf.progressView setHidden:YES];
            [weakSelf.progressView setProgress:0.f];
        }
    }];
    
    [self.webView setWebViewDidStartLoadHandler:^(WKWebView *webview) {
        NSLog(@"加载开始了---------");
    }];
    
    [self.webView setWebViewDidLoadFailedHandler:^(WKWebView *webview, NSError  *error) {
        NSLog(@"加载失败了：%@",error);
    }];
    
    [self.webView setWebViewShouldContinueHandler:^(WKWebView *webView, WKNavigationAction *navigationAction, void (^decisionHandler)(WKNavigationActionPolicy)) {
        
        decisionHandler(WKNavigationActionPolicyAllow);
    }];
}

- (void)navigationBackAction:(UIButton *)button {
    self.webView.webView.canGoBack ? [self.webView.webView goBack] : [self navigationCloseAction:button];
}

- (void)navigationCloseAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setAddress:(NSString *)address {
    _address = address;
    [self.webView loadURL:self.address];
}

- (void)setLocalHtmlName:(NSString *)localHtmlName {
    _localHtmlName = localHtmlName;
    [self.webView loadLocalHtmlWithName:localHtmlName];
}

- (HBWebView *)webView {
    if (!_webView) {
        _webView = [[HBWebView alloc] initWithFrame:CGRectZero configuration:nil];
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor blueColor];
    }
    return _progressView;
}

- (UIButton *)navBackButton {
    if (!_navBackButton) {
        _navBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_navBackButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [_navBackButton setFrame:CGRectMake(0, 0, 30, 30)];
        [_navBackButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
        [_navBackButton addTarget:self action:@selector(navigationBackAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navBackButton;
}

- (UIButton *)navCloseButton {
    if (!_navCloseButton) {
        _navCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_navCloseButton setImage:[UIImage imageNamed:@"nav_close"] forState:UIControlStateNormal];
        [_navCloseButton setFrame:CGRectMake(0, 0, 30, 30)];
        [_navCloseButton setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
        [_navCloseButton addTarget:self action:@selector(navigationCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navCloseButton;
}

@end
