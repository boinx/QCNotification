#import "QCNotificationSenderPlugIn.h"


@interface QCNotificationSenderPlugIn ()

@end


@implementation QCNotificationSenderPlugIn

@dynamic inputNotificationObject;
@dynamic inputNotificationName;
@dynamic inputNotificationUserInfo;
@dynamic inputDistributedNotification;
@dynamic inputSend;

+ (NSDictionary *)attributes
{
	return @{
		QCPlugInAttributeNameKey: @"Notification Sender",
		QCPlugInAttributeDescriptionKey: @"Observes notifications that are send via NSNotificationCenter or NSDistributedNotificationCenter",
		QCPlugInAttributeCopyrightKey: @"© 2015 Maximilian 'McZonk' Christ.",
//		QCPlugInAttributeCategoriesKey: @[
//			@"Source",
//			@"Source/System"
//		],
//		QCPlugInAttributeExamplesKey: @[
//			@"iTunes.qtz",
//		],
	};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// inputs
	
	if([key isEqualToString:@"inputNotificationObject"])
	{
		return @{ QCPortAttributeNameKey: @"Object" };
	}
	
	if([key isEqualToString:@"inputNotificationName"])
	{
		return @{ QCPortAttributeNameKey: @"Name" };
	}
	
	if([key isEqualToString:@"inputNotificationUserInfo"])
	{
		return @{ QCPortAttributeNameKey: @"User Info" };
	}
	
	if([key isEqualToString:@"inputDistributedNotification"])
	{
		return @{
			QCPortAttributeNameKey: @"Distributed",
			QCPortAttributeDefaultValueKey: @NO,
		};
	}
	
	if([key isEqualToString:@"inputSend"])
	{
		return @{ QCPortAttributeNameKey: @"Send" };
	}
	
	return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode)timeMode
{
	return kQCPlugInTimeModeIdle;
}

- (instancetype)init
{
	self = [super init];
	if(self != nil)
	{

	}
	return self;
}

- (void)dealloc
{

}

- (BOOL)startExecution:(id<QCPlugInContext>)context
{
	return YES;
}

- (void)enableExecution:(id<QCPlugInContext>)context
{
}

- (BOOL)execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	if([self didValueForInputKeyChange:@"inputSend"] && self.inputSend)
	{
		NSString *notificationName = self.inputNotificationName;
		if(notificationName.length != 0)
		{
			NSString *notificationObject = self.inputNotificationObject;
			if(notificationObject.length == 0)
			{
				notificationObject = nil;
			}
		
			NSDictionary *notificationUserInfo = self.inputNotificationUserInfo;
			if(notificationUserInfo.count == 0)
			{
				notificationUserInfo = nil;
			}
		
			BOOL distributedNotification = self.inputDistributedNotification;

			NSNotificationCenter *notificationCenter = nil;
			if(distributedNotification)
			{
				notificationCenter = NSDistributedNotificationCenter.defaultCenter;
			}
			else
			{
				notificationCenter = NSNotificationCenter.defaultCenter;
			}
			
			[notificationCenter postNotificationName:notificationName object:notificationObject userInfo:notificationUserInfo];
		}
	}
	
	return YES;
}

- (void)disableExecution:(id<QCPlugInContext>)context
{
	
}

- (void)stopExecution:(id<QCPlugInContext>)context
{
}

@end
