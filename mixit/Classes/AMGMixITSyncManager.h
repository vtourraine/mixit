//
//  AMGMixITSyncManager.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2017 Studio AMANgA. All rights reserved.
//

@import Foundation;

@protocol AMGMixITSyncManagerDelegate;


@interface AMGMixITSyncManager : NSObject

@property (nonatomic, assign, getter = isSyncing, readonly) BOOL syncing;
@property (nonatomic, strong, nonnull ,readonly) NSManagedObjectContext *context;

@property (nonatomic, weak, nullable) id <AMGMixITSyncManagerDelegate> delegate;

+ (nonnull instancetype)MixITSyncManagerWithContext:(nonnull NSManagedObjectContext *)context;

- (BOOL)startSyncForYear:(nonnull NSNumber *)year;

@end


@protocol AMGMixITSyncManagerDelegate <NSObject>

- (void)syncManagerDidStartSync:(nonnull AMGMixITSyncManager *)syncManager;
- (void)syncManager:(nonnull AMGMixITSyncManager *)syncManager didFailSyncWithError:(nullable NSError *)error;
- (void)syncManagerDidFinishSync:(nonnull AMGMixITSyncManager *)syncManager;

@end
