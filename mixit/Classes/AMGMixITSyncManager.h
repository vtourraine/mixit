//
//  AMGMixITSyncManager.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

@import Foundation;

@protocol AMGMixITSyncManagerDelegate;

@interface AMGMixITSyncManager : NSObject

@property (nonatomic, assign, getter = isSyncing, readonly) BOOL syncing;
@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

@property (nonatomic, weak) id <AMGMixITSyncManagerDelegate> delegate;

+ (instancetype)MixITSyncManagerWithContext:(NSManagedObjectContext *)context;

- (BOOL)startSync;

@end


@protocol AMGMixITSyncManagerDelegate <NSObject>

- (void)syncManagerDidStartSync:(AMGMixITSyncManager *)syncManager;
- (void)syncManager:(AMGMixITSyncManager *)syncManager didFailSyncWithError:(NSError *)error;
- (void)syncManagerDidFinishSync:(AMGMixITSyncManager *)syncManager;

@end