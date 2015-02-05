#import <Quartz/Quartz.h>


@interface QCNotificationSenderPlugIn : QCPlugIn

@property (assign) NSString *inputNotificationObject;
@property (assign) NSString *inputNotificationName;
@property (assign) NSDictionary *inputNotificationUserInfo;
@property (assign) BOOL inputDistributedNotification;
@property (assign) BOOL inputSend;

@end
