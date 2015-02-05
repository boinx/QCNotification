#import "QCNotificationObserverPlugIn.h"


static const NSUInteger MaxNotificationsCount = 24;


@interface QCNotificationObserverPlugIn ()

@property (nonatomic, strong) dispatch_queue_t notificationQueue;

@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, copy) NSString *notificationObject;
@property (nonatomic, copy) NSString *notificationName;

@property (nonatomic, strong) NSMutableArray *notifications;

@property (nonatomic, assign) BOOL signal;

@end


@implementation QCNotificationObserverPlugIn

@dynamic inputNotificationObject;
@dynamic inputNotificationName;
@dynamic inputDistributedNotification;

@dynamic outputNotificationObject;
@dynamic outputNotificationName;
@dynamic outputNotificationUserInfo;
@dynamic outputSignal;

+ (NSDictionary *)attributes
{
	return @{
		QCPlugInAttributeNameKey: @"Notification Observer",
		QCPlugInAttributeDescriptionKey: @"Observes notifications that are send via NSNotificationCenter or NSDistributedNotificationCenter",
		QCPlugInAttributeCopyrightKey: @"© 2015 Maximilian 'McZonk' Christ.",
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
	
	if([key isEqualToString:@"inputDistributedNotification"])
	{
		return @{
			QCPortAttributeNameKey: @"Distributed",
			QCPortAttributeDefaultValueKey: @NO,
		};
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
		self.notificationQueue = dispatch_queue_create("QCNotificationObserverPlugIn.noticationQueue", DISPATCH_QUEUE_SERIAL);
		
		self.notifications = [[NSMutableArray alloc] initWithCapacity:MaxNotificationsCount];
	}
	return self;
}

- (void)dealloc
{
	dispatch_sync(self.notificationQueue, ^{
		NSNotificationCenter *notificationCenter = self.notificationCenter;
		NSString *notificationObject = self.notificationObject;
		NSString *notificationName = self.notificationName;
		[notificationCenter removeObserver:self name:notificationName object:notificationObject];
	});
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
	if([self didValueForInputKeyChange:@"inputNotificationObject"] || [self didValueForInputKeyChange:@"inputNotificationName"] || [self didValueForInputKeyChange:@"inputDistributedNotification"])
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
		
		BOOL distributedNotification = self.inputDistributedNotification;
		
		dispatch_sync(self.notificationQueue, ^{
			// remove old observer
			{
				NSNotificationCenter *notificationCenter = self.notificationCenter;
				NSString *notificationObject = self.notificationObject;
				NSString *notificationName = self.notificationName;
				
				[notificationCenter removeObserver:self name:notificationName object:notificationObject];
					
				self.notificationCenter = nil;
				self.notificationObject = nil;
				self.notificationName = nil;
			}
			
			// add new observer
			if(distributedNotification)
			{
				NSDistributedNotificationCenter *notificationCenter = [NSDistributedNotificationCenter defaultCenter];
				[notificationCenter addObserver:self selector:@selector(handleNotification:) name:notificationName object:notificationObject suspensionBehavior:NSNotificationSuspensionBehaviorHold];
				self.notificationCenter = notificationCenter;
			}
			else
			{
				NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
				[notificationCenter addObserver:self selector:@selector(handleNotification:) name:notificationName object:notificationObject];
				self.notificationCenter = notificationCenter;
			}

			self.notificationObject = notificationObject;
			self.notificationName = notificationName;
		});
	}
	
	{
		__block NSNotification *notification = nil;
	
		dispatch_sync(self.notificationQueue, ^{
			NSMutableArray *notifications = self.notifications;
			notification = notifications.firstObject;
			if(notification != nil)
			{
				[notifications removeObjectAtIndex:0];
			}
		});
		
		if(notification != nil)
		{
			id<NSObject> object = notification.object;
			if([object isKindOfClass:NSString.class])
			{
				self.outputNotificationObject = (NSString *)object;
			}
			else
			{
				self.outputNotificationObject = NSStringFromClass(object.class);
			}
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
		// remove old observer
		NSNotificationCenter *notificationCenter = self.notificationCenter;
		NSString *notificationObject = self.notificationObject;
		NSString *notificationName = self.notificationName;

		[notificationCenter removeObserver:self name:notificationName object:notificationObject];
				
		self.notificationCenter = nil;
		self.notificationObject = nil;
		self.notificationName = nil;
	});
}

- (void)stopExecution:(id<QCPlugInContext>)context
{
}

- (void)handleNotification:(NSNotification *)notification
{
	dispatch_async(self.notificationQueue, ^{
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
	
		NSMutableArray *notifications = self.notifications;
		if(notifications.count > MaxNotificationsCount)
		{
			[notifications removeObjectsInRange:NSMakeRange(0, notifications.count - MaxNotificationsCount)];
			// TODO: log?
		}
		[notifications addObject:notification];
	});
}

@end
