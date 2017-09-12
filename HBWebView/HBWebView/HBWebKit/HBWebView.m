//
//  HBWebView.m
//  HBWebView
//
//  Created by Patrick W on 2017/9/5.
//  Copyright © 2017年 Original. All rights reserved.
//

#import "HBWebView.h"
#import "HBBridgeHandler.h"

static NSString *const HB_WEBTITLE_KEY = @"title";
static NSString *const HB_WEBPROGRESS_KEY = @"estimatedProgress";
static NSString *const HB_WEBLOADING_KEY = @"loading";

@interface HBWebView()<WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) WKWebViewConfiguration *configuration;
@property (strong, nonatomic) HBBridgeHandler *jsBridge;


@end

@implementation HBWebView

#pragma mark - 初始化方法

- (instancetype)initWithFrame:(CGRect)frame configuration:(HBWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame];
    if (self) {
        self.configuration = configuration ?: [HBWebViewConfiguration defaultConfiguration];
        [self loadView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.configuration = [HBWebViewConfiguration defaultConfiguration];
    [self loadView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.webView.frame = self.bounds;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)loadView {
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.configuration];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    self.jsBridge = [[HBBridgeHandler alloc] initWithWebview:self.webView];
    
    [self addSubview:self.webView];
    
    [self addObservers];
}

#pragma mark - 公有方法

- (void)loadURL:(NSString *)address {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [self.webView loadRequest:request];
}

- (void)loadLocalHtmlWithName:(NSString *)htmlName {    
    NSURL *htmlPath = [[NSBundle mainBundle] URLForResource:htmlName withExtension:@"html"];
    NSString *contentString = [[NSString alloc] initWithContentsOfURL:htmlPath
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
    [self.webView loadHTMLString:contentString baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark - 监听

- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.webView addObserver:self forKeyPath:HB_WEBTITLE_KEY options:options context:nil];
    [self.webView addObserver:self forKeyPath:HB_WEBPROGRESS_KEY options:options context:nil];
    [self.webView addObserver:self forKeyPath:HB_WEBLOADING_KEY options:options context:nil];
}

- (void)removeObservers {
    [self.webView removeObserver:self forKeyPath:HB_WEBTITLE_KEY];
    [self.webView removeObserver:self forKeyPath:HB_WEBPROGRESS_KEY];
    [self.webView removeObserver:self forKeyPath:HB_WEBLOADING_KEY];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context {
    if ([keyPath isEqualToString:HB_WEBTITLE_KEY]) {
        !self.titleChangeHandler ?: self.titleChangeHandler(self.webView, self.webView.title);
        return;
    }
    if ([keyPath isEqualToString:HB_WEBPROGRESS_KEY]) {
        !self.progressChangeHandler ?: self.progressChangeHandler(self.webView, self.webView.estimatedProgress);
        return;
    }
    if ([keyPath isEqualToString:HB_WEBLOADING_KEY]) {
        !self.loadingChangeHandler ?: self.loadingChangeHandler(self.webView, self.webView.loading);
        return;
    }
}

#pragma mark -
//  Web内容开始在网页视图中加载时调用。
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    //开始加载
    !self.webViewDidStartLoadHandler ?: self.webViewDidStartLoadHandler(webView);
}

//  当Web视图加载内容时发生错误时调用。
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    //加载失败
    !self.webViewDidLoadFailedHandler ?: self.webViewDidLoadFailedHandler(webView, error);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    !self.webViewDidLoadFailedHandler ?: self.webViewDidLoadFailedHandler(webView, error);
}

//  导航完成后调用。
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    !self.webViewDidLoadFinishedHandler ?: self.webViewDidLoadFinishedHandler(webView);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *url = navigationAction.request.URL;
    
    if ([url.absoluteString isEqualToString:@"about://blank"]) {
        //空页面
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //打开appstore
    if ([url.absoluteString containsString:@"https://itunes.apple.com/cn/app"]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //电话号码／短信／邮件
    if ([@[@"tel", @"sms", @"mailto"] containsObject:url.scheme]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if (self.webViewShouldContinueHandler) {
        self.webViewShouldContinueHandler(webView, navigationAction, decisionHandler);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    //弹出警告框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:nil];
    [alert show];
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    //弹出选择框
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    //弹出一个输入面板
    completionHandler(@"输入内容");
}

@end
