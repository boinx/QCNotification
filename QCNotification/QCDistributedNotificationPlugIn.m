#import "QCDistributedNotificationPlugIn.h"


@interface QCDistributedNotificationPlugIn ()

@property (nonatomic, strong) dispatch_queue_t notificationQueue;
@property (nonatomic, strong) NSDistributedNotificationCenter *notificationCenter;

@property (nonatomic, copy) NSString *notificationObject;
@property (nonatomic, copy) NSString *notificationName;

@property (nonatomic, copy) NSNotification *notification;

@property (nonatomic, assign) BOOL signal;

@end


@implementation QCDistributedNotificationPlugIn

@dynamic inputNotificationObject;
@dynamic inputNotificationName;

@dynamic outputNotificationObject;
@dynamic outputNotificationName;
@dynamic outputNotificationUserInfo;
@dynamic outputSignal;

+ (NSDictionary *)attributes
{
	return @{
		QCPlugInAttributeNameKey: @"Distributed Notification",
		QCPlugInAttributeDescriptionKey: @"Observes a system-wide notification",
		QCPlugInAttributeCopyrightKey: @"© 2014 Maximilian 'McZonk' Christ.",
		QCPlugInAttributeCategoriesKey: @[
			@"Source",
			@"Source/System"
		],
		QCPlugInAttributeExamplesKey: @[
			@"iTunes.qtz",
		],
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
	
	// outputs
	
	if([key isEqualToString:@"outputNotificationObject"])
	{
		return @{ QCPortAttributeNameKey: @"Object" };
	}
	
	if([key isEqualToString:@"outputNotificationName"])
	{
		return @{ QCPortAttributeNameKey: @"Name" };
	}
	
	if([key isEqualToString:@"outputNotificationUserInfo"])
	{
		return @{ QCPortAttributeNameKey: @"User Info" };
	}
	
	if([key isEqualToString:@"outputSignal"])
	{
		return @{ QCPortAttributeNameKey: @"Signal" };
	}

	return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	return kQCPlugInExecutionModeProvider;
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
		self.notificationQueue = dispatch_queue_create("QCNotificationPlugIn.noticationQueue", DISPATCH_QUEUE_SERIAL);

		NSDistributedNotificationCenter *notificationCenter = [[NSDistributedNotificationCenter alloc] init];
		notificationCenter.suspended = YES;
		self.notificationCenter = notificationCenter;
	}
	return self;
}

- (void)dealloc
{
	dispatch_sync(self.notificationQueue, ^{
		NSDistributedNotificationCenter *notificationCenter = self.notificationCenter;
		NSString *notificationObject = self.notificationObject;
		NSString *notificationName = self.notificationName;
		if(notificationObject != nil || notificationName != nil)
		{
			[notificationCenter removeObserver:self name:notificationName object:notificationObject];
		}
	});
}

- (BOOL)startExecution:(id<QCPlugInContext>)context
{
	return YES;
}

- (void)enableExecution:(id<QCPlugInContext>)context
{
	dispatch_sync(self.notificationQueue, ^{
		self.notificationCenter.suspended = NO;
	});
}

- (BOOL)execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	if([self didValueForInputKeyChange:@"inputNotificationObject"] || [self didValueForInputKeyChange:@"inputNotificationName"])
	{
		NSString *notificationObject = self.inputNotificationObject;
		if(notificationObject.length == 0)
		{
			notificationObject = nil;
		}
		
		NSString *notificationName = self.inputNotificationName;
		if(notificationName.length == 0)
		{
			notificationName = nil;
		}
		
		dispatch_sync(self.notificationQueue, ^{
			NSDistributedNotificationCenter *notificationCenter = self.notificationCenter;

			// remove old observer
			{
				NSString *notificationObject = self.notificationObject;
				NSString *notificationName = self.notificationName;
				if(notificationObject != nil || notificationName != nil)
				{
					[notificationCenter removeObserver:self name:notificationName object:notificationObject];
					
					self.notificationObject = nil;
					self.notificationName = nil;
				}
			}
			
			// add new observer
			{
				if(notificationObject != 0 || notificationName != 0)
				{
					[notificationCenter addObserver:self selector:@selector(handleNotification:) name:notificationName object:notificationObject suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
					
					self.notificationObject = notificationObject;
					self.notificationName = notificationName;
				}
			}
		});
	}
	
	{
		__block NSNotification *notification = nil;
	
		dispatch_sync(self.notificationQueue, ^{
			notification = self.notification;
			if(notification != nil)
			{
				self.notification = nil;
			}
		});
		
		if(notification != nil)
		{
			self.outputNotificationObject = notification.object;
			self.outputNotificationName = notification.name;
			self.outputNotificationUserInfo = notification.userInfo;

			self.outputSignal = YES;
			self.signal = YES;
		}
		else if(self.signal)
		{
			self.outputSignal = NO;
			self.signal = NO;
		}
	}
	
	return YES;
}

- (void)disableExecution:(id<QCPlugInContext>)context
{
	dispatch_sync(self.notificationQueue, ^{
		self.notificationCenter.suspended = YES;
	});
}

- (void)stopExecution:(id<QCPlugInContext>)context
{
}

- (void)handleNotification:(NSNotification *)notification
{
	dispatch_sync(self.notificationQueue, ^{
		// there are notifications that mismatched e.g. object:nil name:com.apple.HIToolbox.frontMenuBarShown
	
		NSString *notificationObject = self.notificationObject;
		if(notificationObject != nil && ![notificationObject isEqual:notification.object])
		{
			return;
		}
		
		NSString *notificationName = self.notificationName;
		if(notificationName != nil && ![notificationName isEqualToString:notification.name])
		{
			return;
		}
	
		self.notification = notification;
	});
}

@end
