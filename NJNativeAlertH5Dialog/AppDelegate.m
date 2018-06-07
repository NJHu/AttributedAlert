//
//  AppDelegate.m
//  NJNativeAlertH5Dialog
//
//  Created by HuXuPeng on 2018/6/2.
//  Copyright © 2018年 njhu. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [UIStoryboard storyboardWithName:@"AlertDetail" bundle:NSBundle.mainBundle].instantiateInitialViewController;
    
    return YES;
}


@end
