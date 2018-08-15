//
//  AppDelegate.h
//  in-AppPurchase
//
//  Created by 卢腾达 on 2018/3/8.
//  Copyright © 2018年 卢腾达. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (AppDelegate *)theAppDelegate;

- (BOOL)buysomething:(NSString *)pName;
@end

