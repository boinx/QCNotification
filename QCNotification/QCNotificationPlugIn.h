#import <Quartz/Quartz.h>


@interface QCNotificationPlugIn : QCPlugIn

@property (assign) NSString *inputNotificationObject;
@property (assign) NSString *inputNotificationName;

@property (assign) NSString *outputNotificationObject;
@property (assign) NSString *outputNotificationName;
@property (assign) NSDictionary *outputNotificationUserInfo;
@property (assign) BOOL outputSignal;

@end
