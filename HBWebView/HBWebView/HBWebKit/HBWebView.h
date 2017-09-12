//
//  HBWebView.h
//  HBWebView
//
//  Created by Patrick W on 2017/9/5.
//  Copyright © 2017年 Original. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "HBWebViewConfiguration.h"

typedef void(^hb_webViewTitleDidChangedHandler)(WKWebView *webView, NSString *newTitle);
typedef void(^hb_webViewProgressDidChangedHandler)(WKWebView *webView, double progress);
typedef void(^hb_webViewLoadingDidChangedHandler)(WKWebView *webview, BOOL loading);
typedef void(^hb_webViewDidStartLoadHandler)(WKWebView *webView);
typedef void(^hb_webViewShouldContinueHandler)(WKWebView *webView, WKNavigationAction *navigationAction, void (^decisionHandler)(WKNavigationActionPolicy));
typedef void(^hb_webViewDidLoadFailedHandler)(WKWebView *webView, NSError *error);
typedef void(^hb_webViewDidLoadFinishedHandler)(WKWebView *webView);

@interface HBWebView : UIView

@property (strong, nonatomic, readonly) WKWebView *webView;

@property (copy, nonatomic) hb_webViewTitleDidChangedHandler titleChangeHandler;
@property (copy, nonatomic) hb_webViewProgressDidChangedHandler progressChangeHandler;
@property (copy, nonatomic) hb_webViewLoadingDidChangedHandler loadingChangeHandler;
@property (copy, nonatomic) hb_webViewDidStartLoadHandler webViewDidStartLoadHandler;
@property (copy, nonatomic) hb_webViewShouldContinueHandler webViewShouldContinueHandler;
@property (copy, nonatomic) hb_webViewDidLoadFailedHandler webViewDidLoadFailedHandler;
@property (copy, nonatomic) hb_webViewDidLoadFinishedHandler webViewDidLoadFinishedHandler;

- (instancetype)initWithFrame:(CGRect)frame configuration:(HBWebViewConfiguration *)configuration;

- (void)loadURL:(NSString *)address;
- (void)loadLocalHtmlWithName:(NSString *)htmlName;

@end
