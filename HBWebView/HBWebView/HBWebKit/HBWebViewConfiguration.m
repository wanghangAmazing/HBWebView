//
//  HBWebViewConfiguration.m
//  HBWebView
//
//  Created by Patrick W on 2017/9/6.
//  Copyright © 2017年 Original. All rights reserved.
//

#import "HBWebViewConfiguration.h"

@implementation HBWebViewConfiguration

+ (HBWebViewConfiguration *)defaultConfiguration {
    HBWebViewConfiguration *config = [HBWebViewConfiguration new];
    config.processPool = [WKProcessPool new];
    config.allowsInlineMediaPlayback = YES;
    config.selectionGranularity = YES;
    config.userContentController = [[WKUserContentController alloc] init];
    config.suppressesIncrementalRendering = YES;
    
    return config;
}

@end
