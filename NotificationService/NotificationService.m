//
//  NotificationService.m
//  NotificationService
//
//  Created by 常峻玮 on 16/10/27.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // 根据收到的推送request修改推送显示的信息
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [NotificationService]", self.bestAttemptContent.title];
    self.bestAttemptContent.subtitle = [NSString stringWithFormat:@"%@ [NotificationService]", self.bestAttemptContent.subtitle];
    self.bestAttemptContent.body = [NSString stringWithFormat:@"%@ [NotificationService]", self.bestAttemptContent.body];
    
    NSDictionary *lApsDic = self.bestAttemptContent.userInfo[@"aps"];
    NSString *lImageUrl=lApsDic[@"image"];
    if (lImageUrl.length>0) {
        [self loadAttachmentForUrlString:lImageUrl withType:@"png" completionHandle:^(UNNotificationAttachment *attach) {
            if (attach) {
                self.bestAttemptContent.attachments = [NSArray arrayWithObject:attach];
            }
            self.contentHandler(self.bestAttemptContent);
        }];
    }else{
        self.contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

#pragma mark - Private
- (void)loadAttachmentForUrlString:(NSString *)urlStr withType:(NSString *)type completionHandle:(void(^)(UNNotificationAttachment *attach))completionHandler{
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDownloadTask *lTask=[session downloadTaskWithURL:attachmentURL completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"Error:%@", error.localizedDescription);
        } else {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingPathExtension:type]];
            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
            
            NSError *attachmentError = nil;
            attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
            if (attachmentError) {
                NSLog(@"Error:%@", attachmentError.localizedDescription);
            }
        }
        completionHandler(attachment);
    }];
    [lTask resume];
}

@end
