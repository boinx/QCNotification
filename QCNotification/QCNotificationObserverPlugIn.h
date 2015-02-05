#import <Quartz/Quartz.h>


@interface QCNotificationObserverPlugIn : QCPlugIn

@property (assign) NSString *inputNotificationObject;
@property (assign) NSString *inputNotificationName;
@property (assign) BOOL inputDistributedNotification;
@property (assign) BOOL inputQueued;

@property (assign) NSString *outputNotificationObject;
@property (assign) NSString *outputNotificationName;
@property (assign) NSDictionary *outputNotificationUserInfo;
@property (assign) BOOL outputSignal;

@end
