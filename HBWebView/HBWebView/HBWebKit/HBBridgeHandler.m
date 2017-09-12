//
//  HBBridgeHandler.m
//  HBWebView
//
//  Created by Patrick W on 2017/9/12.
//  Copyright © 2017年 Original. All rights reserved.
//

#import "HBBridgeHandler.h"
#import <WebViewJavascriptBridge.h>
#import "HBWebViewController.h"

@interface HBBridgeHandler ()

@property (weak, nonatomic) id webview;
@property (strong, nonatomic) WebViewJavascriptBridge *jsBridge;

@end

@implementation HBBridgeHandler

- (instancetype)init {
    return [self initWithWebview:nil];
}

- (instancetype)initWithWebview:(id)webview {
    self = [super init];
    if (self) {
        self.webview = webview;
        self.jsBridge = [WebViewJavascriptBridge bridgeForWebView:webview];
        [self.jsBridge setWebViewDelegate:[webview superview]];
        [self registerBridges];
    }
    return self;
}

- (void)registerBridges {
    [self.jsBridge registerHandler:@"JSTest" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *className = NSStringFromClass(self.class);
        NSString *cmd = NSStringFromSelector(_cmd);
        NSString *result = [NSString stringWithFormat:@"%@:%@",className, cmd];
        responseCallback(result);
    }];
    
    [self.jsBridge registerHandler:@"GoBack" handler:^(id data, WVJBResponseCallback responseCallback) {
         UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nav popViewControllerAnimated:YES];
    }];
    
    [self.jsBridge registerHandler:@"NewWeb" handler:^(id data, WVJBResponseCallback responseCallback) {
        HBWebViewController *webview = [[HBWebViewController alloc] init];
        webview.address = data;
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nav pushViewController:webview animated:YES];
    }];
}

@end
