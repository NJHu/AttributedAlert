//
//  AlertH5WebView.h
//  NJNativeAlertH5Dialog
//
//  Created by HuXuPeng on 2018/6/2.
//  Copyright © 2018年 njhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface AlertH5WebView : UIView

/**
 弹框, 默认 大小等于 父控件的大小
 @param toastUrlOrHtml 弹框的 Url, 或者 HTML 字符串
 @param view 在哪个 View 里边展示, 默认窗口
 @param jsCallback js 调用的传的 Url, xxx://close?a=1&b=2&c=3
 @param toastFail 加载失败
 @return AlertH5WebView
 */
+ (instancetype)alert:(id)toastUrlOrHtml
               inView:(UIView *)view
           jsCallback:(void(^)(NSURL *callOriUrl, AlertH5WebView *alertView, WKWebView *webView))jsCallback
            toastFail:(void(^)(NSURL *toastUrl, NSError *error, AlertH5WebView *alertView, WKWebView *webView))toastFail;

@end
