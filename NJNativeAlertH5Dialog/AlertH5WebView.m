//
//  AlertH5WebView.m
//  NJNativeAlertH5Dialog
//
//  Created by HuXuPeng on 2018/6/2.
//  Copyright © 2018年 njhu. All rights reserved.
//

#import "AlertH5WebView.h"


static NSString *const DYAlertScheme = @"DYAlert";

@interface AlertH5WebView ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
/** jsCallback */
@property (nonatomic, copy) void(^jsCallback)(NSURL *callOriUrl, AlertH5WebView *alertView, WKWebView *webView);
/** toastFail */
@property (nonatomic, copy) void(^toastFail)(NSURL *toastUrl, NSError *error, AlertH5WebView *alertView, WKWebView *webView);
/** 加载的菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *juHua;
@end

@implementation AlertH5WebView
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
            toastFail:(void(^)(NSURL *toastUrl, NSError *error, AlertH5WebView *alertView, WKWebView *webView))toastFail {
    NSMutableURLRequest *request = nil;
    NSString *html = nil;
    
    if ([toastUrlOrHtml isKindOfClass:[NSURL class]]) {
        request = [[NSMutableURLRequest alloc] initWithURL:toastUrlOrHtml];
        if (!request) {
            NSError *error = [NSError errorWithDomain:@"参数错误" code:-1 userInfo: nil];
            !toastFail ?: toastFail(toastUrlOrHtml, error, nil, nil);
            return nil;
        }
    }else if ([toastUrlOrHtml isKindOfClass:[NSString class]] && [toastUrlOrHtml length]) {
        html = toastUrlOrHtml;
    } else {
        return nil;
    }
    
    AlertH5WebView *alertView = [[self alloc] initWithFrame:view.bounds];
    if (view) {
        [view addSubview:alertView];
    }else {
        alertView.frame = UIApplication.sharedApplication.delegate.window.bounds;
        [UIApplication.sharedApplication.delegate.window addSubview:alertView];
    }
    alertView.toastFail = toastFail;
    alertView.jsCallback = jsCallback;
    if (request) {
        [alertView.webView loadRequest:request];
    }else {
        [alertView.webView loadHTMLString:html baseURL:nil];
    }
    
    return alertView;
}

#pragma mark - navigationDelegate.导航监听
// 1, 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if ([navigationAction.request.URL.scheme.lowercaseString isEqualToString:DYAlertScheme.lowercaseString]) {
        __weak typeof(self) weakSelf = self;
        __weak typeof(self.webView) weakWebView = self.webView;
        !self.jsCallback ?: self.jsCallback(navigationAction.request.URL, weakSelf, weakWebView);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    [self.juHua startAnimating];
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 3, 6, 加载 HTTPS 的链接，需要权限认证时调用  \  如果 HTTPS 是用的证书在信任列表中这不要此代理方法
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    if (trust) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust: trust]);
    }else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}
// 4, 在收到响应后，决定是否跳转, 在收到响应后，决定是否跳转和发送请求之前那个允许配套使用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// 1-2, 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}
// 8, WKNavigation导航错误
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.juHua stopAnimating];
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.webView) weakWebView = self.webView;
    !self.toastFail ?: self.toastFail(webView.URL, error, weakSelf, weakWebView);
}

//当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用回调函数
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    [self.juHua stopAnimating];
    [webView reload];
}


#pragma mark - WKNavigationDelegate-网页监听
// 2, 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}
// 5,内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}
// 7页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.juHua stopAnimating];
}
// 9页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.juHua stopAnimating];
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.webView) weakWebView = self.webView;
    !self.toastFail ?: self.toastFail(webView.URL, error, weakSelf, weakWebView);
}

#pragma mark - addWebView
- (void)addWebView {
    //初始化偏好设置属性：preferences
    WKPreferences *preferences = [WKPreferences new];
    //The minimum font size in points default is 0;
    preferences.minimumFontSize = 0;
    //是否支持JavaScript
    preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    // 原生交互方法
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    //    [userContentController addScriptMessageHandler:<#(nonnull id<WKScriptMessageHandler>)#> name:<#(nonnull NSString *)#>]
    
    //初始化一个WKWebViewConfiguration对象
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    // 检测各种特殊的字符串：比如电话、网站
    config.dataDetectorTypes = UIDataDetectorTypeAll;
    // 播放视频
    config.allowsInlineMediaPlayback = YES;
    
    config.preferences = preferences;
    
    config.userContentController = userContentController;
    
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) configuration:config];
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.scrollView.backgroundColor = [UIColor clearColor];
    //滑动返回看这里
    webView.allowsBackForwardNavigationGestures = NO;
    
    webView.navigationDelegate = self;
    
    if (@available(iOS 11.0, *)){
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    webView.scrollView.contentInset = UIEdgeInsetsZero;
    webView.scrollView.scrollIndicatorInsets = webView.scrollView.contentInset;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.scrollView.bounces = NO;
    
    [self addSubview:webView];
    self.webView = webView;
}

#pragma mark - 菊花
- (UIActivityIndicatorView *)juHua {
    if(!_juHua) {
        _juHua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _juHua.hidesWhenStopped = YES;
        _juHua.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _juHua.layer.cornerRadius = 5;
        [self addSubview:_juHua];
    }
    return _juHua;
}


#pragma mark - 初始化设置
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUIOnce];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUIOnce];
}

- (void)setupUIOnce {
    self.backgroundColor = [UIColor clearColor];
    [self addWebView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.juHua.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.juHua attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.juHua attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)dealloc {
    NSLog(@"%@==%s", self, __func__);
}

@end
