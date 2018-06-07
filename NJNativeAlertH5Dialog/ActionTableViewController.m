//
//  ActionTableViewController.m
//  NJNativeAlertH5Dialog
//
//  Created by HuXuPeng on 2018/6/2.
//  Copyright © 2018年 njhu. All rights reserved.
//

#import "ActionTableViewController.h"
#import "AlertH5WebView.h"

@interface ActionTableViewController ()

@end

@implementation ActionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"alert" withExtension:@"html"];
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    
    [AlertH5WebView alert:url inView:nil jsCallback:^(NSURL *callOriUrl, AlertH5WebView *alertView, WKWebView *webView) {
        
        NSLog(@"%@", callOriUrl);
        NSLog(@"%@", alertView);
        NSLog(@"%@", webView);
        [alertView removeFromSuperview];
        
    } toastFail:^(NSURL *toastUrl, NSError *error, AlertH5WebView *alertView, WKWebView *webView) {
        
        NSLog(@"%@", toastUrl);
        NSLog(@"%@", alertView);
        NSLog(@"%@", webView);
    }];
}

@end
