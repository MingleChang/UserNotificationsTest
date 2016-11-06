//
//  NotificationViewController.m
//  NotificationContent
//
//  Created by 常峻玮 on 16/10/27.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

static NSString *kCategoryTestInputKey=@"category.test.input";
static NSString *kCategoryTestConfirmKey=@"category.test.confirm";

@interface NotificationViewController () <UNNotificationContentExtension>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    if (notification.request.content.attachments.count==0) {
        self.imageView.image=[UIImage imageNamed:@"push_image"];
    }else{
        UNNotificationAttachment *lAttachment=notification.request.content.attachments.firstObject;
        if (lAttachment) {
            if ([lAttachment.URL startAccessingSecurityScopedResource]) {
                self.imageView.image = [UIImage imageWithContentsOfFile:lAttachment.URL.path];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [lAttachment.URL stopAccessingSecurityScopedResource];
                });
            }
        }
    }
    self.titleLabel.text=notification.request.content.title;
    self.contentLabel.text=notification.request.content.body;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion{
    if ([response.actionIdentifier isEqualToString:kCategoryTestInputKey]) {
        UNTextInputNotificationResponse *inputResponse=(UNTextInputNotificationResponse *)response;
        NSString *lString=inputResponse.userText;
        self.contentLabel.text=lString;
    }else if ([response.actionIdentifier isEqualToString:kCategoryTestConfirmKey]) {
        self.contentLabel.text=@"Confirm";
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //这里如果点击的action类型为UNNotificationActionOptionForeground，
        //则即使completion设置成Dismiss的，通知也不能消失
        completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
    });
    
}
@end
