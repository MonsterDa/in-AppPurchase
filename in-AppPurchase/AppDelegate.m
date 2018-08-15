//
//  AppDelegate.m
//  in-AppPurchase
//
//  Created by 卢腾达 on 2018/3/8.
//  Copyright © 2018年 卢腾达. All rights reserved.
//

#import "AppDelegate.h"
#import <StoreKit/StoreKit.h>
#import "PDKeyChain.h"
#import "ZJCustomHUD/ZJCustomHud.h"

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

@interface AppDelegate ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
+ (AppDelegate *)theAppDelegate{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)buysomething:(NSString *)pName{
    
    if (pName.length == 0) {
        return NO;
    }
    if (![SKPaymentQueue canMakePayments]) {
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您的手机没有打开程序内付费购买"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        
        [alerView show];
        return NO;
    }
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:pName, nil]];
    request.delegate = self;
    [request start];
    [ZJCustomHud showWithStatus:@"正在购买，请稍候。。。"];
    return YES;
}

//Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                // 购买中，不用管
                break;
            case SKPaymentTransactionStatePurchased:
                
                [self verifyPurchaseWithPaymentTransaction:transaction];
                
                //如果有多个类型产品可通过判断产品ID前缀区分
                if ([transaction.payment.productIdentifier containsString:@""]) {
                }else{
                }
                
                break;
            case SKPaymentTransactionStateFailed:
                [ZJCustomHud dismiss];
                if(transaction.error.code != SKErrorPaymentCancelled) {
                    [ZJCustomHud showWithText:@"购买失败，请重试" WithDurations:2.0];
                } else {
                    [ZJCustomHud showWithText:@"购买失败，请重试" WithDurations:2.0];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [ZJCustomHud dismiss];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [ZJCustomHud showWithText:@"完成" WithDurations:4];
                break;
            case SKPaymentTransactionStateDeferred:
                // 购买中，不用管
                break;
            default:
                break;
        }
    }
}
// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    // 调用finishTransaction后，会调用这个，不用管
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    // 用户购买非消耗产品后，可以恢复这些购买，在调用了[[SKPaymentQueue defaultQueue] restoreCompletedTransactions]后，如果还原出错，然后调用这个
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    //用户购买非消耗产品后，可以恢复这些购买，在调用了[[SKPaymentQueue defaultQueue] restoreCompletedTransactions]后，如果之前有购买的，会回调- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions，然后调用这个
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads{
    //
}

// Sent when a user initiates an IAP buy from the App Store
- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product{
    // 这里是从app store购买而不是应用内的时候，调用这个
    return YES;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    if (response.products.count == 0) {

        [ZJCustomHud dismiss];
        [ZJCustomHud showWithText:@"购买失败，请重试" WithDurations:4.0];
        return;
    }
    for (SKProduct *product in response.products) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)requestDidFinish:(SKRequest *)request{
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [ZJCustomHud dismiss];
    [ZJCustomHud showWithText:@"购买失败，请重试" WithDurations:2.0];
}

/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
- (void)verifyPurchaseWithPaymentTransaction:(SKPaymentTransaction *)transaction {
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    
    //以下自己做校验用 此处应该让后台处理验证
        NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
        NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

        NSURL *url = [NSURL URLWithString:SANDBOX];
        NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
        requestM.HTTPBody = bodyData;
        requestM.HTTPMethod = @"POST";
        //创建连接并发送同步请求
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];

        if (error) {
            NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
            [ZJCustomHud showWithText:error.localizedDescription WithDurations:2.0];
            return;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    
}



@end
