//
//  AMGAppDelegate.h
//  mixit
//
//  Created by Vincent Tourraine on 30/04/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

@import UIKit;

@interface AMGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext       *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel         *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
