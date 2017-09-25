//
//  AMGAppDelegate.m
//  mixit
//
//  Created by Vincent Tourraine on 30/04/14.
//  Copyright (c) 2014-2017 Studio AMANgA. All rights reserved.
//

#import "AMGAppDelegate.h"

#import <AFNetworkActivityIndicatorManager.h>

#import "UIColor+MiXiT.h"

#import "AMGMixITSyncManager.h"
#import "AMGTalksViewController.h"

@implementation AMGAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    UIColor *purple = [UIColor mixitPurple];
    UIColor *orange = [UIColor mixitOrange];

    [[UINavigationBar appearance] setTintColor:orange];
    [[UINavigationBar appearance] setBarTintColor:purple];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    self.window.tintColor = purple;

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    AMGMixITSyncManager *syncManager = [AMGMixITSyncManager MixITSyncManagerWithContext:self.managedObjectContext];

    AMGTalksViewController *viewController = [[AMGTalksViewController alloc] init];
    viewController.syncManager = syncManager;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    if (@available(iOS 11.0, *)) {
        navigationController.navigationBar.prefersLargeTitles = YES;
    }
    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        } 
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mixit" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"mixit.sqlite"];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }    

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
