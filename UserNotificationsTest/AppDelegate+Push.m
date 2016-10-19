//
//  AppDelegate+Push.m
//  Shell
//
//  Created by 常峻玮 on 16/10/1.
//  Copyright © 2016年 Todd. All rights reserved.
//

#import "AppDelegate+Push.h"
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end
@implementation AppDelegate (Push)
- (void)push_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    if ([UIDevice currentDevice].systemVersion.doubleValue>=10) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted==YES) {
                NSLog(@"request authorization succeeded!");
                [[UNUserNotificationCenter currentNotificationCenter]setDelegate:self];
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
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
{
    NSLog(@"Registering device for push notifications..."); // iOS 8
    [application registerForRemoteNotifications];
}

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

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler:(void(^)())completionHandler
{
    NSLog(@"Received push notification: %@, identifier: %@", notification, identifier); // iOS 8
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification
{
    NSLog(@"Received push notification: %@", notification);
}

#pragma mark - UNUserNotificationCenter Delegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
}
@end
