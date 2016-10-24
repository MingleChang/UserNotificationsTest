//
//  AppDelegate+Push.m
//  Shell
//
//  Created by 常峻玮 on 16/10/1.
//  Copyright © 2016年 Todd. All rights reserved.
//

#import "AppDelegate+Push.h"
#import <UserNotifications/UserNotifications.h>

static NSString *kCategoryTestKey=@"category.test";
static NSString *kCategoryTestInputKey=@"category.test.input";
static NSString *kCategoryTestConfirmKey=@"category.test.confirm";

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end
@implementation AppDelegate (Push)
- (void)push_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    if ([UIDevice currentDevice].systemVersion.doubleValue>=10) {
        [[UNUserNotificationCenter currentNotificationCenter]setDelegate:self];
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted==YES) {
                NSLog(@"request authorization succeeded!");
                [application registerForRemoteNotifications];
                [self registerNotificationCategory];
            }else{
                NSLog(@"request authorization failed!");
                NSLog(@"Error:%@",error);
            }
        }];
    }else if ([UIDevice currentDevice].systemVersion.doubleValue>=8) {// iOS 8
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
//        [application registerUserNotificationSettings:settings];
    } else {
//        NSLog(@"Registering device for push notifications..."); // iOS 7 and earlier
//        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
}
//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
//{
//    NSLog(@"Registering device for push notifications..."); // iOS 8
//    [application registerForRemoteNotifications];
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Registration successful, bundle identifier: %@, device token: %@",[NSBundle.mainBundle bundleIdentifier], deviceToken);
    NSString *pushToken = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"device token: %@",pushToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register: %@", error);
}

//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler:(void(^)())completionHandler
//{
//    NSLog(@"Received push notification: %@, identifier: %@", notification, identifier); // iOS 8
//    completionHandler();
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification
//{
//    NSLog(@"Received push notification: %@", notification);
//}

#pragma mark - UNUserNotificationCenter Delegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //在IOS10之前，当应用处于前台时，是无法展示收到的通知到，但是在IOS10，如果我们希望在应用内也展示通知的话，只需执行下面的方法
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//这个代理方法会在用户与你推送的通知进行交互时被调用，包括用户通过通知打开了你的应用，或者点击或者触发了某个action之后
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSString *lString=@"点击了通知";
    if ([response.actionIdentifier isEqualToString:kCategoryTestInputKey]) {
        UNTextInputNotificationResponse *inputResponse=(UNTextInputNotificationResponse *)response;
        lString=[NSString stringWithFormat:@"点击了input,输入内容为:%@",inputResponse.userText];
    }else if([response.actionIdentifier isEqualToString:kCategoryTestConfirmKey]){
        lString=@"点击了confirm";
    }
    UIAlertController *lAlertController=[UIAlertController alertControllerWithTitle:lString message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *lOKAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [lAlertController addAction:lOKAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:lAlertController animated:YES completion:nil];
    completionHandler();
}

#pragma mark - Notification Category
//注册category，根据推送的不同的categoryid可以创建不同的action
-(void)registerNotificationCategory{
    //一个带有输入的Action
    UNTextInputNotificationAction *lTextAction=[UNTextInputNotificationAction actionWithIdentifier:kCategoryTestInputKey title:@"text" options:UNNotificationActionOptionForeground textInputButtonTitle:@"send" textInputPlaceholder:@"please"];
    
    UNNotificationAction *lConfirmAction=[UNNotificationAction actionWithIdentifier:kCategoryTestConfirmKey title:@"Confirm" options:UNNotificationActionOptionForeground];
    
    UNNotificationCategory *lCategory=[UNNotificationCategory categoryWithIdentifier:kCategoryTestKey actions:@[lTextAction,lConfirmAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    [[UNUserNotificationCenter  currentNotificationCenter]setNotificationCategories:[NSSet setWithObjects:lCategory, nil]];
}
@end
