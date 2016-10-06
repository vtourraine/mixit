//
//  AMGAppDelegate.h
//  mixit
//
//  Created by Vincent Tourraine on 30/04/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

@import UIKit;


@interface AMGAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong, nullable) UIWindow *window;

@property (nonatomic, strong, nullable, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, nullable, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, nullable, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (nullable NSURL *)applicationDocumentsDirectory;

@end
